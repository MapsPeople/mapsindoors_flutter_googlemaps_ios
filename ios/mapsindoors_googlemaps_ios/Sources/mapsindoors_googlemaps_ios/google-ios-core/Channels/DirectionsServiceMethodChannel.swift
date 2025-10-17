//
//  DirectionsServiceMethodChannel.swift
//  mapsindoors_ios
//
//  Created by Martin Hansen on 21/02/2023.
//

import Flutter
import Foundation
import MapsIndoors
import MapsIndoorsCodable
import MapsIndoorsCore
import UIKit

public class DirectionsServiceMethodChannel: NSObject {
    static var avoidWayTypes = [MPHighway]()
    static var excludeWayTypes = [MPHighway]()
    static var isDeparture = true
    static var travelMode = MPTravelMode.walking
    static var date: Date?

    enum Methods: String {
        case DSE_create
        case DSE_addAvoidWayType
        case DSE_clearAvoidWayType
        case DSE_setIsDeparture
        case DSE_getRoute
        case DSE_setTravelMode
        case DSE_setTime
        case DSE_addExcludeWayType
        case DSE_clearExcludeWayType

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void = switch self {
            case .DSE_create: create
            case .DSE_addAvoidWayType: addAvoidWayType
            case .DSE_clearAvoidWayType: clearAvoidWayType
            case .DSE_setIsDeparture: setIsDeparture
            case .DSE_getRoute: getRoute
            case .DSE_setTravelMode: setTravelMode
            case .DSE_setTime: setTime
            case .DSE_addExcludeWayType: addExcludeWayType
            case .DSE_clearExcludeWayType: clearExcludeWayType
            }

            runner(arguments, mapsIndoorsData, result)
        }

        func create(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            DirectionsServiceMethodChannel.resetStaticVariables()
            result(nil)
        }

        func addAvoidWayType(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DSE_addAvoidWayType", details: nil))
                return
            }

            guard let wayType = args["wayType"] as? String else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DSE_addAvoidWayType", details: nil))
                return
            }

            let avoidWaytype = MPHighway(typeString: wayType)
            if avoidWaytype != MPHighway.unclassified {
                DirectionsServiceMethodChannel.avoidWayTypes.append(avoidWaytype)
            }

            result(nil)
        }

        func clearAvoidWayType(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            DirectionsServiceMethodChannel.avoidWayTypes.removeAll()
            result(nil)
        }

        func setIsDeparture(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DSE_setIsDeparture", details: nil))
                return
            }

            guard let isDeparture = args["isDeparture"] as? Bool else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DSE_setIsDeparture", details: nil))
                return
            }

            DirectionsServiceMethodChannel.isDeparture = isDeparture
            result(nil)
        }

        func getRoute(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Could not read arguments", message: "DSE_getRoute", details: nil))
                return
            }
            guard let originJson = args["origin"] as? String else {
                result(FlutterError(code: "Could not read origin point", message: "DSE_getRoute", details: nil))
                return
            }
            guard let destinationJson = args["destination"] as? String else {
                result(FlutterError(code: "Could not read destination point", message: "DSE_getRoute", details: nil))
                return
            }
            guard let optimizeRoute = args["optimize"] as? Bool else {
                result(FlutterError(code: "Could not read destination point", message: "DSE_getRoute", details: nil))
                return
            }

            var origin: MPPoint?
            var destination: MPPoint?
            do {
                origin = try JSONDecoder().decode(MPPoint.self, from: Data(originJson.utf8))
                destination = try JSONDecoder().decode(MPPoint.self, from: Data(destinationJson.utf8))
            } catch {
                result(FlutterError(code: "Unable to parse origin or destination point", message: "DSE_getRoute", details: nil))
            }

            guard let origin, let destination else {
                result(FlutterError(code: "Origin or destination is nil", message: Methods.DSE_getRoute.rawValue, details: nil))
                return
            }

            var routeStops: [MPPoint]?
            if let stops = args["stops"] as? [String] {
                routeStops = stops.compactMap { try? JSONDecoder().decode(MPPoint.self, from: Data($0.utf8)) }
            }

            let query = MPDirectionsQuery(originPoint: origin, destinationPoint: destination)
            query.stopsPoints = routeStops
            query.optimizeRoute = optimizeRoute
            if !DirectionsServiceMethodChannel.avoidWayTypes.isEmpty {
                query.avoidWayTypes = DirectionsServiceMethodChannel.avoidWayTypes
            }
            if !DirectionsServiceMethodChannel.excludeWayTypes.isEmpty {
                query.excludeWayTypes = DirectionsServiceMethodChannel.excludeWayTypes
            }

            if let date = DirectionsServiceMethodChannel.date {
                if DirectionsServiceMethodChannel.isDeparture {
                    query.departure = date
                } else {
                    query.arrival = date
                }
            }

            query.travelMode = DirectionsServiceMethodChannel.travelMode

            Task {
                do {
                    guard let route = try await MPMapsIndoors.shared.directionsService.routingWith(query: query) else {
                        result(nil)
                        return
                    }
                    guard let routeData = try? JSONEncoder().encode(MPRouteInternal(withRoute: route)) else {
                        result(FlutterError(code: "Could not parse route", message: Methods.DSE_getRoute.rawValue, details: nil))
                        return
                    }
                    
                    let routeRoute = String(data: routeData, encoding: String.Encoding.utf8)
                    result(["route": routeRoute, "error": "null"])
                } catch {
                    result(FlutterError(code: error.localizedDescription, message: Methods.DSE_getRoute.rawValue, details: nil))
                    return
                }
            }
        }

        func setTravelMode(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DSE_setTravelMode", details: nil))
                return
            }

            guard let travelMode = args["travelMode"] as? String else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DSE_setTravelMode", details: nil))
                return
            }

            var mpTravelMode = MPTravelMode.walking

            switch travelMode {
            case "walking": mpTravelMode = MPTravelMode.walking
            case "bicycling": mpTravelMode = MPTravelMode.bicycling
            case "driving": mpTravelMode = MPTravelMode.driving
            case "transit": mpTravelMode = MPTravelMode.transit
            default:
                result(FlutterError(code: "TravelMode not found", message: "DSE_setTravelMode", details: nil))
            }

            DirectionsServiceMethodChannel.travelMode = mpTravelMode
            result(nil)
        }

        func setTime(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DSE_setTime", details: nil))
                return
            }

            guard let time = args["time"] as? Int else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DSE_setTime", details: nil))
                return
            }

            DirectionsServiceMethodChannel.date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
            result(nil)
        }

        func addExcludeWayType(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Initialized called without arguments", message: "DSE_addExcludeWayType", details: nil))
                return
            }

            guard let wayType = args["wayType"] as? String else {
                result(FlutterError(code: "Could not initialise MapsIndoors", message: "DSE_addExcludeWayType", details: nil))
                return
            }

            let excludeWayType = MPHighway(typeString: wayType)
            if excludeWayType != MPHighway.unclassified {
                DirectionsServiceMethodChannel.excludeWayTypes.append(excludeWayType)
            }

            result(nil)
        }

        func clearExcludeWayType(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            DirectionsServiceMethodChannel.excludeWayTypes.removeAll()
            result(nil)
        }
    }

    static func resetStaticVariables() {
        avoidWayTypes = []
        excludeWayTypes = []
        isDeparture = true
        travelMode = MPTravelMode.walking
        date = nil
    }
}
