import Flutter
import Foundation
import MapsIndoors
import MapsIndoorsCodable
import MapsIndoorsCore
import UIKit

protocol MapsIndoorsReadyDelegate: AnyObject {
    func isReady(error: MPError?)
}

protocol LiveDataDelegate: AnyObject {
    func dataReceived(liveUpdate: MPLiveUpdate)
}

public class MapsIndoorsData: NSObject {
    var delegate: [MapsIndoorsReadyDelegate] = []

    weak var liveDataDelegate: LiveDataDelegate?

    var mapControlListenerDelegate: MapControlDelegate?

    var mapView: FlutterMapView?

    var mapControl: MPMapControl?

    var isMapControlInitialized: Bool { mapControl != nil }

    var isMapsIndoorsReady: Bool { MPMapsIndoors.shared.ready }

    func mapsIndoorsReady(error: MPError?) {
        for item in delegate {
            item.isReady(error: error)
        }
    }

    var mapControlMethodChannel: FlutterMethodChannel?

    var directionsRendererMethodChannel: FlutterMethodChannel?

    var mapsIndoorsMethodChannel: FlutterMethodChannel?

    var mapControlFloorSelector: FlutterMethodChannel?

    var positionProvider: FlutterPositionProvider?

    var directionsRenderer: MPDirectionsRenderer?

    var floorSelector: MPCustomFloorSelector?
}

public class CustomFloorSelector: UIView, MPCustomFloorSelector {
    public var isAutoFloorChangeEnabled = true

    public weak var methodChannel: FlutterMethodChannel?

    public weak var building: MapsIndoors.MPBuilding? {
        didSet {
            if oldValue?.buildingId != building?.buildingId {
                onShow()
            }
        }
    }

    public var delegate: MapsIndoors.MPFloorSelectorDelegate?

    public var floorIndex: NSNumber?

    init(isAutoFloorChangeEnabled: Bool = true, methodChannel: FlutterMethodChannel) {
        super.init(frame: CGRect())
        self.methodChannel = methodChannel
        self.isAutoFloorChangeEnabled = isAutoFloorChangeEnabled
        delegate = FloorSelectorDelegate(floorSelector: self)
    }

    required init?(coder _: NSCoder) {
        super.init(frame: CGRect())
    }

    public func onShow() {
        if let building {
            let floors = building.floors?.values.map { MPFloorCodable(withFloor: $0) }
            if let jsonData = try? JSONEncoder().encode(floors) {
                let resultJson = String(decoding: jsonData, as: UTF8.self)
                Task { @MainActor in
                    methodChannel?.invokeMethod("setList", arguments: resultJson)
                }
            }
        }
        Task { @MainActor in
            methodChannel?.invokeMethod("show", arguments: ["show": true])
        }
    }

    public func onHide() {
        Task { @MainActor in
            methodChannel?.invokeMethod("show", arguments: ["show": false])
        }
    }

    public func onUserPositionFloorChange(floorIndex: Int) {
        Task { @MainActor in
            methodChannel?.invokeMethod("setUserPositionFloor", arguments: floorIndex)
        }
    }
    
    func onZoomLevelChanged(zoom: Float) {
        Task { @MainActor in
            methodChannel?.invokeMethod("zoomLevelChanged", arguments: zoom)
        }
    }
}

public class FloorSelectorDelegate: MPFloorSelectorDelegate {
    private weak var customFloorSelector: CustomFloorSelector?

    init(floorSelector: CustomFloorSelector) {
        customFloorSelector = floorSelector
    }

    public func onFloorIndexChanged(_ floorIndex: NSNumber) {
        if customFloorSelector?.isAutoFloorChangeEnabled == true {
            customFloorSelector?.floorIndex = floorIndex
        }
    }
}

public class FlutterPositionProvider: MPPositionProvider {
    public var latestPosition: MapsIndoors.MPPositionResult?

    public var name = "default"
    public weak var delegate: MapsIndoors.MPPositionProviderDelegate?
    public weak var mapsIndoorsData: MapsIndoorsData?

    public func setLatestPosition(positionResult: MPPositionResult) {
        if latestPosition?.floorIndex != positionResult.floorIndex {
            let floorSelector = mapsIndoorsData?.floorSelector as? CustomFloorSelector
            floorSelector?.onUserPositionFloorChange(floorIndex: positionResult.floorIndex)
        }

        delegate?.onPositionUpdate(position: positionResult)
        latestPosition = positionResult
    }
}

public class MapControlLiveDataDelegate: LiveDataDelegate {
    var methodChannel: FlutterMethodChannel?

    init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }

    func dataReceived(liveUpdate: MapsIndoors.MPLiveUpdate) {
        guard let location = MPMapsIndoors.shared.locationWith(locationId: liveUpdate.itemId), let domain = liveUpdate.topic.domainType else { return }

        guard let locationData = try? JSONEncoder().encode(MPLocationCodable(withLocation: location)) else { return }

        let locationString = String(decoding: locationData, as: UTF8.self)
        let map = ["location": locationString, "domainType": domain]
        Task { @MainActor in
            methodChannel?.invokeMethod("onLiveLocationUpdate", arguments: map)
        }
    }
}

public class MapControlDelegate: MPMapControlDelegate {
    private var methodChannel: FlutterMethodChannel
    private weak var mapsIndoorsData: MapsIndoorsData?

    var respondToTap = false
    var consumeTap = false

    var respondToTapIcon = false
    var consumeTapIcon = false

    var respondToDidChangeFloorIndex = false

    var respondToDidChangeBuilding = false

    var respondToDidChangeVenue = false

    var respondToDidChangeLocation = false
    var consumeChangeLocation = false

    var respondToDidTapInfoWindow = false

    var respondToCameraEvents = false

    init(methodChannel: FlutterMethodChannel, miData: MapsIndoorsData) {
        self.methodChannel = methodChannel
        self.mapsIndoorsData = miData
    }

    public func didTap(coordinate: MPPoint) -> Bool {
        if respondToTap {
            var map = [String: Any?]()
            if let pointData = try? JSONEncoder().encode(coordinate) {
                map["point"] = String(decoding: pointData, as: UTF8.self)
            }
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onMapClick.description, arguments: map)
            }
            return consumeTap
        } else {
            return false
        }
    }

    public func didTapIcon(location: MPLocation) -> Bool {
        guard respondToTapIcon else { return false }

        Task { @MainActor in
            methodChannel.invokeMethod(FlutterCallback.onMarkerClick.description, arguments: location.locationId)
        }
        return consumeTapIcon
    }

    public func didChange(floorIndex: Int) -> Bool {
        if respondToDidChangeFloorIndex {
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onFloorUpdate.description, arguments: floorIndex)
            }
        }
        return false
    }

    public func didChange(selectedVenue: MPVenue?) -> Bool {
        guard let selectedVenue, respondToDidChangeVenue else { return false }
        
        guard let venueData = try? JSONEncoder().encode(MPVenueCodable(withVenue: selectedVenue)) else { return false }
        
        let venueString = String(decoding: venueData, as: UTF8.self)
        Task { @MainActor in
            methodChannel.invokeMethod(FlutterCallback.onVenueFoundAtCameraTarget.description, arguments: venueString)
        }
        return false
    }
    
    public func didChange(selectedBuilding: MPBuilding?) -> Bool {
        guard let selectedBuilding, respondToDidChangeBuilding else { return false }
        
        guard let buildingData = try? JSONEncoder().encode(MPBuildingCodable(withBuilding: selectedBuilding)) else { return false }
        
        let buildingString = String(decoding: buildingData, as: UTF8.self)
        Task { @MainActor in
            methodChannel.invokeMethod(FlutterCallback.onBuildingFoundAtCameraTarget.description, arguments: buildingString)
        }
        
        return false
    }

    public func didChange(selectedLocation: MPLocation?) -> Bool {
        guard let selectedLocation = selectedLocation, respondToDidChangeLocation else { return false }
        
        guard let locationData = try? JSONEncoder().encode(MPLocationCodable(withLocation: selectedLocation)) else { return false }
        
        let locationString = String(decoding: locationData, as: UTF8.self)
        Task { @MainActor in
            methodChannel.invokeMethod(FlutterCallback.onLocationSelected.description, arguments: locationString)
        }
        
        return false
    }

    public func didTapInfoWindow(location: MPLocation) -> Bool {
        if respondToDidTapInfoWindow {
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onInfoWindowClick.description, arguments: location.locationId)
            }
        }
        return false
    }

    public func cameraIdle() -> Bool {
        if respondToCameraEvents {
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 7) // Corresponds to Android MPCameraEvent.IDLE
            }
        }
        return false
    }

    public func cameraWillMove() -> Bool {
        if respondToCameraEvents {
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 5) // Corresponds to Android MPCameraEvent.ON_MOVE
            }
        }
        return false
    }
    
    private var zoom: Float = 0.0
    public func didChangeCameraPosition() -> Bool {
        let z = mapsIndoorsData?.mapControl?.mapsIndoorsZoom ?? zoom
        if z != zoom {
            zoom = z
            if let floorSelector = mapsIndoorsData?.floorSelector as? CustomFloorSelector {
                floorSelector.onZoomLevelChanged(zoom: z)
            }
        }

        if respondToCameraEvents {
            Task { @MainActor in
                methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 5) // Corresponds to Android MPCameraEvent.ON_MOVE
            }
        }
        return false
    }
}

private enum FlutterCallback: String, CustomStringConvertible {
    var description: String { rawValue }

    case onBuildingFoundAtCameraTarget
    case onCameraEvent
    case onFloorUpdate
    case onInfoWindowClick
    case onLocationSelected
    case onMapClick
    case onMarkerClick
    case onVenueFoundAtCameraTarget
}
