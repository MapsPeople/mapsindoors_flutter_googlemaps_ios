import Flutter
import Foundation
import MapsIndoors
import MapsIndoorsCore

/// Bridges the MapsIndoors base-map tile cache onto `DataSetCacheMethodChannel`.
///
/// Base-map tiles are the map provider's own tiles, underneath MapsIndoors. They are cached independently of MapsIndoors content, so a slow tile download never delays a dataset sync.
///
/// The whole tile API on `MPDataSetCacheManager` is public, so nothing here needs an `@_spi` import. The provider that does the work is registered by the map provider itself when the map view is created - `MapBoxProvider` registers a real implementation and `GoogleMapProvider` a no-op that reports the feature unsupported - so the wrapper neither constructs nor registers one.
public class DataSetCacheMethodChannel: NSObject {
    enum Methods: String {
        case DSC_enableBaseMapCaching
        case DSC_isBaseMapCachingSupported
        case DSC_synchronizeBaseMapTiles

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void =
                switch self {
                case .DSC_enableBaseMapCaching: enableBaseMapCaching
                case .DSC_isBaseMapCachingSupported: isBaseMapCachingSupported
                case .DSC_synchronizeBaseMapTiles: synchronizeBaseMapTiles
                }

            runner(arguments, mapsIndoorsData, result)
        }

        /// The error payload Dart's `MPError.fromJson` reads, built the same way Android builds it.
        ///
        /// Serialised rather than interpolated, so a message containing a quote cannot produce invalid JSON.
        func errorJson(code: Int, message: String) -> String? {
            guard let data = try? JSONSerialization.data(withJSONObject: ["code": code, "message": message]) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }

        /// Returns nil for anything unrecognised, so an unknown scope fails here as it does on Android rather than silently caching the widest one.
        func cachingScope(_ name: String?) -> MPDataSetCachingScope? {
            switch name {
            case "BASIC": .basic
            case "DETAILED": .detailed
            case "FULL": .full
            default: nil
            }
        }

        /// Maps an SDK error onto the codes Dart's `MPError` declares, which are the Android SDK's numbering.
        ///
        /// iOS raw values are a different namespace and must never be forwarded as-is: `requestTimedOut` is 100 on iOS, which is `MPError.invalidApiKey` in Dart. Anything without an Android counterpart becomes `unknownError`, so an unmapped error is never reported as a meaningful one.
        func dartCode(for error: MPError) -> Int {
            switch error {
            case .baseMapCachingNotSupported: MPErrorCode.baseMapCachingNotSupported
            case .networkError, .networkUnreachable: MPErrorCode.networkError
            case .invalidApiKey: MPErrorCode.invalidApiKey
            default: MPErrorCode.unknownError
            }
        }

        func isBaseMapCachingSupported(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result(BaseMapCache.isSupported)
        }

        func enableBaseMapCaching(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard BaseMapCache.isSupported else {
                result(
                    errorJson(
                        code: MPErrorCode.baseMapCachingNotSupported,
                        message: "The Google Maps provider cannot cache base-map tiles"))
                return
            }

            // The map provider registers the cache implementation when the map view is created, so there is
            // nothing to cache into before then. Android enforces the same precondition.
            guard mapsIndoorsData.mapView != nil else {
                result(
                    errorJson(
                        code: MPErrorCode.baseMapCachingNotRegistered,
                        message: "Base-map tile caching needs a MapsIndoors map view. Build a MapsIndoorsWidget before calling enableBaseMapCaching"))
                return
            }

            guard let apiKey = MPMapsIndoors.shared.apiKey else {
                result(
                    errorJson(
                        code: MPErrorCode.sdkNotInitialized,
                        message: "No API key is loaded. Call loadMapsIndoors before enableBaseMapCaching"))
                return
            }

            // `styleSource` is not read here, and does not need to be. No entry point on `MPDataSetCacheManager` takes a style: the Mapbox adapter resolves it at cache time from the style the map is set up to render, which includes a `mapStyleUri` set on the widget, since `MapsIndoorsView` turns that into `useMapsIndoorsStyle(false)`. A custom style the app passes is therefore the one cached anyway.

            let scopeName = arguments?["scope"] as? String
            guard let scope = cachingScope(scopeName) else {
                result(
                    FlutterError(
                        code: "-1", message: "Unknown caching scope \(scopeName ?? "null")", details: nil))
                return
            }

            let manager = MPMapsIndoors.shared.datasetCacheManager

            // Both calls report whether the SDK accepted the change. Dropping that would let this
            // return success while nothing is flagged, and the sync would then cache nothing and still
            // report success - the silent failure the 9001 guard exists to prevent.
            let enabled: Bool
            if let dataSet = manager.dataSetForCurrentMapsIndoorsAPIKey() {
                enabled = manager.setBaseMapTilesEnabled(true, cacheItem: dataSet.cacheItem)
            } else {
                enabled = manager.addDataSet(apiKey, cachingScope: scope, baseMapTilesEnabled: true) != nil
            }

            guard enabled else {
                result(
                    errorJson(
                        code: MPErrorCode.unknownError,
                        message: "The SDK did not enable base-map tile caching for this dataset"))
                return
            }

            mapsIndoorsData.baseMapCachingEnabled = true
            result(nil)
        }

        func synchronizeBaseMapTiles(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard BaseMapCache.isSupported else {
                result(
                    errorJson(
                        code: MPErrorCode.baseMapCachingNotSupported,
                        message: "The Google Maps provider cannot cache base-map tiles"))
                return
            }

            guard mapsIndoorsData.baseMapCachingEnabled else {
                result(
                    errorJson(
                        code: MPErrorCode.baseMapCachingNotRegistered,
                        message: "Base-map tile caching is not enabled. Call enableBaseMapCaching first"))
                return
            }

            guard !mapsIndoorsData.baseMapCacheSyncInProgress else {
                // Same code, message and details as Android's guard, so Dart sees one PlatformException
                // shape on both platforms. Note this deliberately does not follow the inverted
                // FlutterError(code: <message>, message: <method>) convention of the neighbouring
                // channels - parity with Android matters more here than matching that.
                result(
                    FlutterError(
                        code: "-1",
                        message: "A base-map tile synchronization is already running",
                        details: nil))
                return
            }

            let manager = MPMapsIndoors.shared.datasetCacheManager
            let channel = mapsIndoorsData.dataSetCacheMethodChannel

            // `@MainActor` so the download - which runs for minutes - resumes on the platform thread before
            // touching `result`.
            mapsIndoorsData.baseMapCacheSyncInProgress = true

            Task { @MainActor in
                defer { mapsIndoorsData.baseMapCacheSyncInProgress = false }
                do {
                    try await manager.synchronizeBaseMapTiles(progress: { fraction in
                        Task { @MainActor in
                            channel?.invokeMethod("onBaseMapCacheProgress", arguments: ["fraction": fraction])
                        }
                    })
                    result(nil)
                } catch let error as MPError {
                    result(errorJson(code: dartCode(for: error), message: error.description))
                } catch {
                    result(errorJson(code: MPErrorCode.unknownError, message: error.localizedDescription))
                }
            }
        }
    }
}

/// The codes Dart's `MPError` declares, which are the Android SDK's numbering.
enum MPErrorCode {
    static let networkError = 10
    static let unknownError = 20
    static let sdkNotInitialized = 22
    static let invalidApiKey = 100
    static let baseMapCachingNotSupported = 9000
    static let baseMapCachingNotRegistered = 9001
}
