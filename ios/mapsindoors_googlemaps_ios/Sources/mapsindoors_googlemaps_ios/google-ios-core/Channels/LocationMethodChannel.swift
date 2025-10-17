import Flutter
import Foundation
import MapsIndoorsCodable
import MapsIndoorsCore
import UIKit

public class LocationMethodChannel: NSObject {
    enum Methods: String {
        case LOC_setLocationSettingsSelectable

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void

            switch self {
            case .LOC_setLocationSettingsSelectable: runner = setLocationSettingsSelectable
            }

            runner(arguments, mapsIndoorsData, result)
        }

        func setLocationSettingsSelectable(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setLocationSettingsSelectable called without arguments", message: Methods.LOC_setLocationSettingsSelectable.rawValue, details: nil))
                return
            }
            guard let locationId = arguments?["id"] as? String else {
                result(FlutterError(code: "Could not find id for Location", message: Methods.LOC_setLocationSettingsSelectable.rawValue, details: nil))
                return
            }
            guard let location = MPMapsIndoors.shared.locationWith(locationId: locationId) else {
                result(FlutterError(code: "Could not find location with id", message: Methods.LOC_setLocationSettingsSelectable.rawValue, details: nil))
                return
            }
            guard let settings = args["settings"] as? String else {
                result(FlutterError(code: "Could not read location settings", message: Methods.LOC_setLocationSettingsSelectable.rawValue, details: nil))
                return
            }

            let decoder = JSONDecoder()
            do {
                let locationSettings = try decoder.decode(MPLocationSettings.self, from: Data(settings.utf8))

                location.locationSettings = locationSettings
                result(nil)
            } catch {
                result(FlutterError(code: "Could not parse location settings", message: Methods.LOC_setLocationSettingsSelectable.rawValue, details: nil))
            }
        }
    }
}
