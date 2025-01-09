import Flutter
import GoogleMaps
import MapsIndoorsCore
import MapsIndoorsGoogleMaps

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var mapsIndoorsData: MapsIndoorsData

    init(
        messenger: FlutterBinaryMessenger,
        mapsIndoorsData: MapsIndoorsData
    ) {
        self.messenger = messenger
        self.mapsIndoorsData = mapsIndoorsData
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            arguments: args,
            binaryMessenger: messenger,
            mapsIndoorsData: mapsIndoorsData)
    }
}

class FLNativeView: NSObject, FlutterPlatformView, MPMapControlDelegate, FlutterMapView {
    
    private var _GMSView: GMSMapView
    private var mapsIndoorsData: MapsIndoorsData
    private var mapConfig: MPMapConfigCodable?
    private let googleApiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String ?? ""
    
    init(
        frame: CGRect,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        mapsIndoorsData: MapsIndoorsData
    ) {
        let arguments = args as? [String: Any]
        self.mapsIndoorsData = mapsIndoorsData;
        GMSServices.provideAPIKey(googleApiKey)

        if let configArgs = arguments?["mapConfig"] as? String {
            mapConfig = try! JSONDecoder().decode(MPMapConfigCodable.self, from: configArgs.data(using: .utf8)!)
        }

        let cameraPosition = if let initialCamPos = arguments?["initialCameraPosition"] as? String, let position = try? JSONDecoder().decode(CameraPosition.self, from: initialCamPos.data(using: .utf8)!) {
            Self.makeGMSCameraPosition(cameraPosition: position)
        } else {
            GMSCameraPosition()
        }

        _GMSView = GMSMapView(frame: frame, camera: cameraPosition)
        super.init()
        mapsIndoorsData.mapView = self
        
        if (MPMapsIndoors.shared.ready) {
            mapsIndoorsIsReady()
        } else {
            mapsIndoorsData.delegate.append(MIReadyDelegate(view: self))
        }
        
        // To fix an odd bug, where the map center would be in the top left corner of the view.
        // It should be the center of the view.
        _GMSView.moveCamera(GMSCameraUpdate.setCamera(cameraPosition))
    }
    
    func view() -> UIView {
        return _GMSView
    }
    
    func mapsIndoorsIsReady() {
        guard mapsIndoorsData.mapView != nil else { return }

        DispatchQueue.main.async { [self] in
            let config = MPMapConfig(gmsMapView: _GMSView, googleApiKey: googleApiKey)
            if let mapControl = MPMapsIndoors.createMapControl(mapConfig: config) {
                mapControl.showUserPosition = mapConfig?.showUserPosition ?? false
                mapsIndoorsData.mapControl = mapControl
                mapsIndoorsData.directionsRenderer = nil
                mapsIndoorsData.mapControlMethodChannel?.invokeMethod("create", arguments: nil)
                mapControl.floorSelector = mapsIndoorsData.floorSelector
            }
        }
    }
    
    func animateCamera(cameraUpdate: CameraUpdate, duration: Int) throws {
        guard let update = makeGMSCameraUpdate(cameraUpdate: cameraUpdate) else {
            throw MPError.unknownError
        }
        _GMSView.animate(with: update)
    }
    
    func moveCamera(cameraUpdate: CameraUpdate) throws {
        guard let update = makeGMSCameraUpdate(cameraUpdate: cameraUpdate) else {
            throw MPError.unknownError
        }
        _GMSView.moveCamera(update)
    }

    static func makeGMSCameraPosition(cameraPosition: CameraPosition) -> GMSCameraPosition {
        GMSCameraPosition(latitude: CLLocationDegrees(cameraPosition.target.latitude),
                          longitude: CLLocationDegrees(cameraPosition.target.longitude),
                          zoom: cameraPosition.zoom,
                          bearing: CLLocationDirection(floatLiteral: Double(cameraPosition.bearing)),
                          viewingAngle: Double(cameraPosition.tilt))
    }
    
    func makeGMSCameraUpdate(cameraUpdate: CameraUpdate) -> GMSCameraUpdate? {
        let update: GMSCameraUpdate
        
        switch cameraUpdate.mode {
        case "fromPoint":
            guard let point = cameraUpdate.point else {
                return nil
            }
            update = GMSCameraUpdate.setTarget(point.coordinate)
        case "fromBounds":
            guard let bounds = cameraUpdate.bounds else {
                return nil
            }
            update = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: bounds.northEast, coordinate: bounds.southWest), withPadding: CGFloat(integerLiteral: cameraUpdate.padding!))
        case "zoomBy":
            update = (GMSCameraUpdate.zoom(by: cameraUpdate.zoom!))
        case "zoomTo":
            update = (GMSCameraUpdate.zoom(to: cameraUpdate.zoom!))
        case "fromCameraPosition":
            guard let position = cameraUpdate.position else {
                return nil
            }
            update = (GMSCameraUpdate.setCamera(GMSCameraPosition(latitude: CLLocationDegrees(position.target.latitude), longitude: CLLocationDegrees(position.target.longitude), zoom: position.zoom, bearing: CLLocationDirection(floatLiteral: Double(position.bearing)), viewingAngle: Double(position.tilt)) ))
        default:
            return nil
        }
        
        return update
    }
    
    func showCompassOnRotate(_ show: Bool) throws {
        _GMSView.settings.compassButton = show
    }
}

class MIReadyDelegate: MapsIndoorsReadyDelegate {
    let view: FLNativeView
    
    init(view: FLNativeView) {
        self.view = view
    }
    
    func isReady(error: MPError?) {
        if (error == MPError.invalidApiKey || error == MPError.networkError || error == MPError.unknownError ) {
            //TODO: Do nothing i guees?
        }else {
            view.mapsIndoorsIsReady()
        }
    }
}

private class MPMapConfigCodable: Codable {
    var mapsindoorsTransitionLevel: Int?
    var textSize: Int?
    var showFloorSelector: Bool?
    var showInfoWindowOnLocationClicked: Bool?
    var showUserPosition: Bool?
    var useDefaultMapsIndoorsStyle: Bool?
}
