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

    var liveDataDelegate: LiveDataDelegate?

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

    public var methodChannel: FlutterMethodChannel?

    public var building: MapsIndoors.MPBuilding?

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
                methodChannel?.invokeMethod("setList", arguments: resultJson)
            }
        }
        let map = ["show": true]
        methodChannel?.invokeMethod("show", arguments: map)
    }

    public func onHide() {
        let map = ["show": false]
        methodChannel?.invokeMethod("show", arguments: map)
    }

    public func onUserPositionFloorChange(floorIndex: Int) {
        methodChannel?.invokeMethod("setUserPositionFloor", arguments: floorIndex)
    }
}

public class FloorSelectorDelegate: MPFloorSelectorDelegate {
    private var customFloorSelector: CustomFloorSelector

    init(floorSelector: CustomFloorSelector) {
        customFloorSelector = floorSelector
    }

    public func onFloorIndexChanged(_ floorIndex: NSNumber) {
        if customFloorSelector.isAutoFloorChangeEnabled {
            customFloorSelector.floorIndex = floorIndex
        }
    }
}

public class FlutterPositionProvider: MPPositionProvider {
    public var latestPosition: MapsIndoors.MPPositionResult?

    public var name = "default"
    public var delegate: MapsIndoors.MPPositionProviderDelegate?
    public var mapsIndoorsData: MapsIndoorsData?

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
        let domain = liveUpdate.topic.domainType
        let location = MPMapsIndoors.shared.locationWith(locationId: liveUpdate.itemId)
        if location != nil, domain != nil {
            let locationData = try? JSONEncoder().encode(MPLocationCodable(withLocation: location!))
            if let locationData {
                let locationString = String(decoding: locationData, as: UTF8.self)
                let map = ["location": locationString, "domainType": domain]
                methodChannel?.invokeMethod("onLiveLocationUpdate", arguments: map)
            }
        }
    }
}

public class MapControlDelegate: MPMapControlDelegate {
    var methodChannel: FlutterMethodChannel

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

    init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }

    public func didTap(coordinate: MPPoint) -> Bool {
        if respondToTap {
            var map = [String: Any?]()
            if let pointData = try? JSONEncoder().encode(coordinate) {
                map["point"] = String(decoding: pointData, as: UTF8.self)
            }
            methodChannel.invokeMethod(FlutterCallback.onMapClick.description, arguments: map)
            return consumeTap
        } else {
            return false
        }
    }

    public func didTapIcon(location: MPLocation) -> Bool {
        if respondToTapIcon {
            methodChannel.invokeMethod(FlutterCallback.onMarkerClick.description, arguments: location.locationId)
            return consumeTapIcon
        } else {
            return false
        }
    }

    public func didChange(floorIndex: Int) -> Bool {
        if respondToDidChangeFloorIndex {
            var map = [String: Any]()
            map["floor"] = floorIndex
            methodChannel.invokeMethod(FlutterCallback.onFloorUpdate.description, arguments: map)
        }
        return false
    }

    public func didChange(selectedVenue: MPVenue?) -> Bool {
        if respondToDidChangeVenue {
            var venueString: String?
            if let selectedVenue, let venueData = try? JSONEncoder().encode(MPVenueCodable(withVenue: selectedVenue)) {
                venueString = String(decoding: venueData, as: UTF8.self)
            }
            methodChannel.invokeMethod(FlutterCallback.onVenueFoundAtCameraTarget.description, arguments: venueString)
        }
        return false
    }

    public func didChange(selectedBuilding: MPBuilding?) -> Bool {
        if respondToDidChangeBuilding {
            var buildingString: String?
            if let selectedBuilding,
               let buildingData = try? JSONEncoder().encode(MPBuildingCodable(withBuilding: selectedBuilding)) {
                buildingString = String(decoding: buildingData, as: UTF8.self)
            }
            methodChannel.invokeMethod(FlutterCallback.onBuildingFoundAtCameraTarget.description, arguments: buildingString)
        }
        return false
    }

    public func didChange(selectedLocation: MPLocation?) -> Bool {
        if respondToDidChangeLocation {
            var locationString: String?
            if let selectedLocation,
               let locationData = try? JSONEncoder().encode(MPLocationCodable(withLocation: selectedLocation)) {
                locationString = String(decoding: locationData, as: UTF8.self)
            }
            methodChannel.invokeMethod(FlutterCallback.onLocationSelected.description, arguments: locationString)
        }
        return false
    }

    public func didTapInfoWindow(location: MPLocation) -> Bool {
        if respondToDidTapInfoWindow {
            methodChannel.invokeMethod(FlutterCallback.onInfoWindowClick.description, arguments: location.locationId)
        }
        return false
    }

    public func cameraIdle() -> Bool {
        if respondToCameraEvents {
            methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 7) // Corresponds to Android MPCameraEvent.IDLE
        }
        return false
    }

    public func cameraWillMove() -> Bool {
        if respondToCameraEvents {
            methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 5) // Corresponds to Android MPCameraEvent.ON_MOVE
        }
        return false
    }

    public func didChangeCameraPosition() -> Bool {
        if respondToCameraEvents {
            methodChannel.invokeMethod(FlutterCallback.onCameraEvent.description, arguments: 5) // Corresponds to Android MPCameraEvent.ON_MOVE
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
