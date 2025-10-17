//
//  MapControlFloorSelectorChannel.swift
//  mapsindoors_ios
//
//  Created by Martin Hansen on 21/02/2023.
//

import Flutter
import Foundation
import MapsIndoorsCodable

public class MapControlFloorSelectorChannel: NSObject {
    enum Methods: String {
        case FSE_onFloorChanged

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel: FlutterMethodChannel?) {
            guard let methodChannel else { return }

            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult, _ methodChannel: FlutterMethodChannel) -> Void

            switch self {
            case .FSE_onFloorChanged: runner = onFloorChanged
            }

            runner(arguments, mapsIndoorsData, result, methodChannel)
        }

        func onFloorChanged(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel: FlutterMethodChannel) {
            guard let floorJson = arguments?["floor"] as? String else {
                result(FlutterError(code: "Could not read floor", message: "FSE_onFloorChanged", details: nil))
                return
            }

            do {
                let floor = try JSONDecoder().decode(MPFloorCodable.self, from: floorJson.data(using: .utf8)!)
                let floorIndex = floor.floorIndex?.intValue ?? 0
                mapsIndoorsData.mapControl?.select(floorIndex: floorIndex)
            } catch {
                result(FlutterError(code: "Could not parse floor", message: "FSE_onFloorChanged", details: error.localizedDescription))
            }
        }
    }
}
