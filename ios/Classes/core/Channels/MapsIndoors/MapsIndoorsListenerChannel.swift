//
//  MapsIndoorsListenerChannel.swift
//  mapsindoors_ios
//
//  Created by Martin Hansen on 21/02/2023.
//

import Flutter
import Foundation
import MapsIndoors
import UIKit

public class MapsIndoorsListenerChannel: NSObject {
    static var delegate: ReadyDelegate? = nil

    enum Methods: String {
        case MIL_onMapsIndoorsReadyListener
        case MIL_onPositionUpdate
        case MIL_onVenueStatusListener

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel: FlutterMethodChannel?) {
            if methodChannel == nil {
                return
            }

            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult, _ methodChannel: FlutterMethodChannel) -> Void = switch self {
            case .MIL_onMapsIndoorsReadyListener: onMapsIndoorsReadyListener
            case .MIL_onPositionUpdate: onPositionUpdate
            case .MIL_onVenueStatusListener: onVenueStatusListener
            }

            runner(arguments, mapsIndoorsData, result, methodChannel!)
        }

        func onMapsIndoorsReadyListener(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel: FlutterMethodChannel) {
            guard let setupListener = arguments?["addListener"] as? Bool else {
                result(FlutterError(code: "Missing parameter to set listener", message: "MIL_onMapsIndoorsReadyListener", details: nil))
                return
            }
            if setupListener {
                MapsIndoorsListenerChannel.delegate = ReadyDelegate(methodChannel: methodChannel)
                mapsIndoorsData.delegate.append(MapsIndoorsListenerChannel.delegate!)
            } else {
                mapsIndoorsData.delegate = mapsIndoorsData.delegate.filter { !($0 is ReadyDelegate) }
            }
        }

        func onPositionUpdate(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel _: FlutterMethodChannel) {
            guard let position = arguments?["position"] as? String else {
                result(FlutterError(code: "Missing parameter to set listener", message: "MIL_onPositionUpdate", details: nil))
                return
            }

            let positionResult = try? JSONDecoder().decode(MPPositionResult.self, from: Data(position.utf8))
            if positionResult != nil {
                mapsIndoorsData.positionProvider?.setLatestPosition(positionResult: positionResult!)
            }
        }

        func onVenueStatusListener(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult, methodChannel: FlutterMethodChannel) {
            // No such thing exists on iOS at time of implementation (iOS SDK 4.5.0)
        }
    }

    class ReadyDelegate: MapsIndoorsReadyDelegate {
        let methodChannel: FlutterMethodChannel

        init(methodChannel: FlutterMethodChannel) {
            self.methodChannel = methodChannel
        }

        func isReady(error: MPError?) {
            if error == MPError.invalidApiKey || error == MPError.networkError || error == MPError.unknownError {
                methodChannel.invokeMethod("onMapsIndoorsReady", arguments: error)
            } else {
                methodChannel.invokeMethod("onMapsIndoorsReady", arguments: nil)
            }
        }
    }
}
