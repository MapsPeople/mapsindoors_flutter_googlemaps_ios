//
//  DirectionsRendererMethodChannel.swift
//  mapsindoors_ios
//
//  Created by Martin Hansen on 21/02/2023.
//

import Flutter
import Foundation
import MapsIndoorsCodable
import MapsIndoorsCore
import UIKit

public class DirectionsRendererMethodChannel: NSObject {
    static var isListeningForLegChanges = false
    // The runtime override. Cached rather than read back off the renderer so that getOptions reports
    // exactly what was set, and so options set before the renderer exists are not lost.
    //
    // Static, where the Android side uses an instance field, because that matches what it describes:
    // mapsIndoorsData.directionsRenderer is created once below and never nilled, so the cache and the
    // renderer live exactly as long as each other. MIN_destroy is the one teardown that invalidates
    // both, and it calls clearOptionsCache.
    //
    // Two cases sit outside that reasoning. Several Flutter engines in one process (add-to-app) share
    // the static, so one engine's override is what the other's getOptions reports; that is accepted
    // here, and is the case the Android comment rejects for its own field. After a hot restart Dart
    // state resets while the static and the renderer both survive, so getOptions reports the previous
    // session's override - which is the truthful answer on iOS, where that renderer really is still
    // styled, and the opposite of Android, where setMapControl builds a fresh one.
    fileprivate static var currentOptions: RendererOptions?
    fileprivate static var currentOptionsJson: String?

    /// Drops the runtime override. Called when MapsIndoors is shut down, after which the cached
    /// options describe a renderer that no longer means anything.
    static func clearOptionsCache() {
        currentOptions = nil
        currentOptionsJson = nil
    }

    enum Methods: String {
        case DRE_clear
        case DRE_clearOptions
        case DRE_finishGuidance
        case DRE_getOptions
        case DRE_getSelectedLegFloorIndex
        case DRE_nextLeg
        case DRE_previousLeg
        case DRE_selectLegIndex
        case DRE_setAnimatedPolyline
        case DRE_setCameraAnimationDuration
        case DRE_setCameraViewFitMode
        case DRE_setDefaultRouteStopIcon
        case DRE_setOnLegSelectedListener
        case DRE_setOptions
        case DRE_setPolyLineColors
        case DRE_setRoute
        case DRE_showRouteLegButtons
        case DRE_useContentOfNearbyLocations

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void

            if mapsIndoorsData.mapControl != nil, mapsIndoorsData.directionsRenderer == nil {
                mapsIndoorsData.directionsRenderer = mapsIndoorsData.mapControl?.newDirectionsRenderer()
                mapsIndoorsData.directionsRenderer?.delegate = DirectionsRendererDelegateImplementation(mapsIndoorsData: mapsIndoorsData)
                // Options set before the renderer existed were only cached; apply them now.
                if let pending = DirectionsRendererMethodChannel.currentOptions {
                    mapsIndoorsData.directionsRenderer?.options = pending.toOptions()
                }
            }

            switch self {
            case .DRE_clear: runner = clear
            case .DRE_clearOptions: runner = clearOptions
            case .DRE_finishGuidance: runner = finishGuidance
            case .DRE_getOptions: runner = getOptions
            case .DRE_getSelectedLegFloorIndex: runner = getSelectedLegFloorIndex
            case .DRE_nextLeg: runner = nextLeg
            case .DRE_previousLeg: runner = previousLeg
            case .DRE_selectLegIndex: runner = selectLegIndex
            case .DRE_setAnimatedPolyline: runner = setAnimatedPolyline
            case .DRE_setCameraAnimationDuration: runner = setCameraAnimationDuration
            case .DRE_setCameraViewFitMode: runner = setCameraViewFitMode
            case .DRE_setDefaultRouteStopIcon: runner = setDefaultRouteStopIcon
            case .DRE_setOnLegSelectedListener: runner = setOnLegSelectedListener
            case .DRE_setOptions: runner = setOptions
            case .DRE_setPolyLineColors: runner = setPolyLineColors
            case .DRE_setRoute: runner = setRoute
            case .DRE_showRouteLegButtons: runner = showRouteLegButtons
            case .DRE_useContentOfNearbyLocations: runner = useContentOfNearbyLocations
            }

            runner(arguments, mapsIndoorsData, result)
        }

        func clear(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            mapsIndoorsData.directionsRenderer?.clear()

            result(nil)
        }

        func finishGuidance(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            // The SDK has one overload taking a non-optional Double and one taking nothing; Dart sends null for "let the SDK derive it".
            if let usagePercentage = arguments?["usagePercentage"] as? Double {
                mapsIndoorsData.directionsRenderer?.finishGuidance(usagePercentage: usagePercentage)
            } else {
                mapsIndoorsData.directionsRenderer?.finishGuidance()
            }

            result(nil)
        }

        func getSelectedLegFloorIndex(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let legIndex = mapsIndoorsData.directionsRenderer?.routeLegIndex
            if legIndex != nil {
                result(mapsIndoorsData.directionsRenderer?.route?.legs[legIndex!].end_location.zLevel.int32Value)
            }

            result(nil)
        }

        func nextLeg(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let renderer = mapsIndoorsData.directionsRenderer else {
                result(FlutterError(code: "Unable to change leg: The directionsRenderer is not set", message: "DRE_nextLeg", details: nil))

                return
            }
            _ = renderer.nextLeg()

            renderer.animate(duration: 5)

            // Sent before the reply, and not from a Task, so the listener has run by the time the caller's await returns.
            if DirectionsRendererMethodChannel.isListeningForLegChanges {
                mapsIndoorsData.directionsRendererMethodChannel?.invokeMethod("onLegSelected", arguments: renderer.routeLegIndex)
            }

            result(nil)
        }

        func previousLeg(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let renderer = mapsIndoorsData.directionsRenderer else {
                result(FlutterError(code: "Unable to change leg: The directionsRenderer is not set", message: "DRE_previousLeg", details: nil))
                return
            }
            let _ = renderer.previousLeg()

            renderer.animate(duration: 5)

            // Sent before the reply, and not from a Task, so the listener has run by the time the caller's await returns.
            if DirectionsRendererMethodChannel.isListeningForLegChanges {
                mapsIndoorsData.directionsRendererMethodChannel?.invokeMethod("onLegSelected", arguments: renderer.routeLegIndex)
            }

            result(nil)
        }

        func selectLegIndex(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DRE_selectLegIndex", details: nil))
                return
            }

            guard let legIndex = args["legIndex"] as? Int else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DRE_selectLegIndex", details: nil))
                return
            }

            guard let renderer = mapsIndoorsData.directionsRenderer else {
                result(FlutterError(code: "Unable to select leg: The directionsRenderer is not set", message: "DRE_selectLegIndex", details: nil))
                return
            }

            guard let route = mapsIndoorsData.directionsRenderer!.route else {
                result(FlutterError(code: "No route set", message: "DRE_selectLegIndex", details: nil))
                return
            }

            guard legIndex >= 0 else {
                result(nil)
                return
            }

            guard legIndex < (route.legs.count) else {
                result(nil)
                return
            }

            renderer.routeLegIndex = legIndex

            renderer.animate(duration: 5)

            // Sent before the reply, and not from a Task, so the listener has run by the time the caller's await returns.
            if DirectionsRendererMethodChannel.isListeningForLegChanges {
                mapsIndoorsData.directionsRendererMethodChannel?.invokeMethod("onLegSelected", arguments: renderer.routeLegIndex)
            }

            result(nil)
        }

        // Deliberately a no-op; the deprecated Dart method points apps at setOptions instead. The iOS SDK has no equivalent to Android's setAnimatedPolyline. The route animation is timed from options.animationSpeed and animationMinDuration, not from animate(duration:), which the SDK documents as the camera animation duration and which setRoute and every leg change here overwrite anyway. Honouring `animated` or `repeating` would mean writing options behind the cache that getOptions reports.
        func setAnimatedPolyline(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result(nil)
        }

        func setOptions(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let json = arguments?["options"] as? String else {
                result(FlutterError(code: "Could not read options", message: "DRE_setOptions", details: nil))
                return
            }

            guard let options = try? JSONDecoder().decode(RendererOptions.self, from: Data(json.utf8)) else {
                result(FlutterError(code: "Could not parse options", message: "DRE_setOptions", details: nil))
                return
            }

            if let invalidKey = options.invalidColorKey() {
                result(FlutterError(code: "\(invalidKey) is not a hex color", message: "DRE_setOptions", details: nil))
                return
            }

            DirectionsRendererMethodChannel.currentOptions = options
            DirectionsRendererMethodChannel.currentOptionsJson = json
            // Assigning options re-styles an already-rendered route immediately. If the renderer does
            // not exist yet this is a no-op and the cache above is applied when it is created.
            mapsIndoorsData.directionsRenderer?.options = options.toOptions()
            result(nil)
        }

        func getOptions(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result(DirectionsRendererMethodChannel.currentOptionsJson)
        }

        func clearOptions(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            DirectionsRendererMethodChannel.currentOptions = nil
            DirectionsRendererMethodChannel.currentOptionsJson = nil
            // A fresh options object leaves every optional property unset, which is what lets the
            // CMS style take over again. fitBounds, fitBoundsPadding and animationRepeating are not
            // optional natively, so those return to their built-in defaults rather than to CMS.
            mapsIndoorsData.directionsRenderer?.options = MPDirectionsRendererOptions()
            result(nil)
        }

        func setCameraAnimationDuration(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result(nil)
        }

        func setCameraViewFitMode(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DRE_setCameraViewFitMode", details: nil))
                return
            }

            guard let cameraFit = args["cameraFitMode"] as? Int else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DRE_setCameraViewFitMode", details: nil))
                return
            }
            let cameraFitMode = MPCameraViewFitMode(rawValue: cameraFit)
            if cameraFitMode != nil {
                mapsIndoorsData.directionsRenderer?.fitMode = cameraFitMode!
            }

            result(nil)
        }

        func setOnLegSelectedListener(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            DirectionsRendererMethodChannel.isListeningForLegChanges = true

            result(nil)
        }

        func setPolyLineColors(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DRE_setPolyLineColors", details: nil))
                return
            }

            guard let color = args["foreground"] as? String else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DRE_setPolyLineColors", details: nil))
                return
            }

            guard let pathColor = parseHexColor(color) else {
                result(FlutterError(code: "Color is not a hex color", message: "DRE_setPolyLineColors", details: nil))
                return
            }

            mapsIndoorsData.directionsRenderer?.pathColor = pathColor
            result(nil)
        }

        func setRoute(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DRE_setRoute", details: nil))
                return
            }

            guard let routeJson = args["route"] as? String else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DRE_setRoute", details: nil))
                return
            }

            do {
                let route = try JSONDecoder().decode(MPRouteInternal.self, from: Data(routeJson.utf8))
                mapsIndoorsData.directionsRenderer?.route = route
                mapsIndoorsData.directionsRenderer?.routeLegIndex = 0
                mapsIndoorsData.directionsRenderer?.animate(duration: 5)
            } catch {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: error.localizedDescription, details: nil))
                return
            }

            result(nil)
        }

        func useContentOfNearbyLocations(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result(nil)
        }

        func showRouteLegButtons(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DRE_showRouteLegButtons", details: nil))
                return
            }

            guard let showButtons = args["show"] as? Bool else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DRE_showRouteLegButtons", details: nil))
                return
            }

            mapsIndoorsData.directionsRenderer?.showRouteLegButtons = showButtons

            result(nil)
        }

        func setDefaultRouteStopIcon(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: Methods.DRE_setDefaultRouteStopIcon.rawValue, details: nil))
                return
            }

            guard let iconUrlString = args["icon"] as? String, let iconUrl = URL(string: iconUrlString) else {
                result(FlutterError(code: "Could not read icon point", message: Methods.DRE_setDefaultRouteStopIcon.rawValue, details: nil))
                return
            }

            Task {
                if let data = try? Data(contentsOf: iconUrl), let icon = UIImage(data: data) {
                    let iconProvider = MPRouteStopIconConfig()
                    iconProvider.image = icon
                    mapsIndoorsData.directionsRenderer?.defaultRouteStopIcon? = iconProvider
                }

                result(nil)
            }
        }
    }
}

private class DirectionsRendererDelegateImplementation: MPDirectionsRendererDelegate {
    private let mapsIndoorsData: MapsIndoorsData
    
    init(mapsIndoorsData: MapsIndoorsData) {
        self.mapsIndoorsData = mapsIndoorsData
    }
    
    public func onLegSelected(legIndex: Int) {
        if DirectionsRendererMethodChannel.isListeningForLegChanges {
            Task { @MainActor in
                mapsIndoorsData.directionsRendererMethodChannel?.invokeMethod("onLegSelected", arguments: legIndex)
            }
        }
    }
}

/// The renderer options sent from Dart.
///
/// Every field is optional: an absent field means "not set", and must not be assigned onto
/// MPDirectionsRendererOptions, so that the solution-served (CMS) style keeps applying to it.
///
/// Kept in this file rather than in IosCore/Models so that no new file is added to IosCore - the
/// iOS core is mirrored into the provider packages one symlink per file, and a new file without a
/// matching symlink is silently missing from the published pod.
fileprivate struct RendererOptions: Codable {
    var strokeColor: String?
    var strokeOpacity: Double?
    var strokeWeight: Double?
    var strokeStyle: String?
    var haloEnabled: Bool?
    var haloColor: String?
    var haloOpacity: Double?
    var haloWeight: Double?
    var animationType: String?
    var animationSpeed: Double?
    var animationMinDuration: Double?
    var animationRepeating: Bool?
    var forceAnimation: Bool?
    var animatedOverlayColor: String?
    var animatedOverlayOpacity: Double?
    var animatedOverlayWeight: Double?
    var fitBounds: Bool?
    var fitBoundsMaxZoom: Double?
    var fitBoundsPadding: Padding?

    struct Padding: Codable {
        var top: Double?
        var left: Double?
        var bottom: Double?
        var right: Double?
    }

    /// The name of the first colour key that is not a hex colour, or nil when they are all fine.
    func invalidColorKey() -> String? {
        let colors = [
            ("strokeColor", strokeColor),
            ("haloColor", haloColor),
            ("animatedOverlayColor", animatedOverlayColor),
        ]
        for (key, value) in colors {
            if value != nil, parseHexColor(value) == nil {
                return key
            }
        }
        return nil
    }

    func toOptions() -> MPDirectionsRendererOptions {
        let options = MPDirectionsRendererOptions()

        if let strokeColor = strokeColor { options.strokeColor = parseHexColor(strokeColor) }
        if let strokeOpacity = strokeOpacity { options.strokeOpacity = NSNumber(value: strokeOpacity) }
        if let strokeWeight = strokeWeight { options.strokeWeight = NSNumber(value: strokeWeight) }
        if let strokeStyle = strokeStyle { options.strokeStyle = RendererOptions.mpStrokeStyle(strokeStyle) }

        // The halo is called backgroundColor on iOS. It is not the "background" of the deprecated
        // setPolyLineColors, which is the base line.
        if let haloEnabled = haloEnabled { options.backgroundColorEnabled = NSNumber(value: haloEnabled) }
        if let haloColor = haloColor { options.backgroundColor = parseHexColor(haloColor) }
        if let haloOpacity = haloOpacity { options.backgroundColorOpacity = NSNumber(value: haloOpacity) }
        if let haloWeight = haloWeight { options.backgroundColorWeight = NSNumber(value: haloWeight) }

        if let animationType = animationType { options.animationType = RendererOptions.mpAnimationType(animationType) }
        if let animationSpeed = animationSpeed { options.animationSpeed = NSNumber(value: animationSpeed) }
        if let animationMinDuration = animationMinDuration { options.animationMinDuration = NSNumber(value: animationMinDuration) }
        if let forceAnimation = forceAnimation { options.forceAnimation = NSNumber(value: forceAnimation) }
        if let animatedOverlayColor = animatedOverlayColor { options.animatedOverlayColor = parseHexColor(animatedOverlayColor) }
        if let animatedOverlayOpacity = animatedOverlayOpacity { options.animatedOverlayOpacity = NSNumber(value: animatedOverlayOpacity) }
        if let animatedOverlayWeight = animatedOverlayWeight { options.animatedOverlayWeight = NSNumber(value: animatedOverlayWeight) }

        // These three are not optional natively, so assigning unconditionally would overwrite a
        // built-in default with a guess.
        if let animationRepeating = animationRepeating { options.animationRepeating = animationRepeating }
        if let fitBounds = fitBounds { options.fitBounds = fitBounds }
        if let fitBoundsMaxZoom = fitBoundsMaxZoom { options.fitBoundsMaxZoom = NSNumber(value: fitBoundsMaxZoom) }
        if let padding = fitBoundsPadding {
            options.fitBoundsPadding = UIEdgeInsets(
                top: padding.top ?? 0,
                left: padding.left ?? 0,
                bottom: padding.bottom ?? 0,
                right: padding.right ?? 0
            )
        }

        return options
    }

    static func mpStrokeStyle(_ value: String) -> MPStrokeStyle? {
        switch value {
        case "solid": return MPStrokeStyle.solid
        case "dashed": return MPStrokeStyle.dashed
        case "dotted": return MPStrokeStyle.dotted
        default: return nil
        }
    }

    static func mpAnimationType(_ value: String) -> MPRouteAnimationType? {
        switch value {
        // Spelled out rather than as `.none`, which Swift would read as Optional.none.
        case "none": return MPRouteAnimationType.none
        case "flow": return MPRouteAnimationType.flow
        case "pulse": return MPRouteAnimationType.pulse
        case "comet": return MPRouteAnimationType.comet
        default: return nil
        }
    }
}

/// The one hex parser in this file. Accepts `#rrggbb` and `#aarrggbb` and returns nil for anything
/// else, so a bad colour becomes a FlutterError rather than a force-unwrapped crash.
private let hexColorPattern = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")

fileprivate func parseHexColor(_ hex: String?) -> UIColor? {
    guard let hex = hex else { return nil }
    let range = NSRange(location: 0, length: hex.utf16.count)
    guard hexColorPattern.matches(in: hex, range: range).count == 1 else { return nil }
    return UIColor(hex: hex)
}
