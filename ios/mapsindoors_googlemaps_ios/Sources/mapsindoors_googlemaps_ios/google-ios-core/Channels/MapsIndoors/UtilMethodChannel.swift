//
//  UtilMethodChannel.swift
//  mapsindoors_ios
//
//  Created by Martin Hansen on 21/02/2023.
//

import Flutter
import Foundation
import MapsIndoors
import MapsIndoorsCore
import UIKit

public class UtilMethodChannel: NSObject {
    enum Methods: String {
        case UTL_geometryArea
        case UTL_geometryIsInside
        case UTL_getPlatformVersion
        case UTL_parseMapClientUrl
        case UTL_pointAngleBetween
        case UTL_pointDistanceTo
        case UTL_polygonDistToClosestEdge
        case UTL_setAutomatedZoomLimit
        case UTL_setCollisionHandling
        case UTL_setEnableClustering
        case UTL_setExtrusionOpacity
        case UTL_setLocationSettings
        case UTL_setTypeLocationSettingsSelectable
        case UTL_setWallOpacity
        case UTL_venueHasGraph

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void = switch self {
            case .UTL_geometryArea: geometryArea
            case .UTL_geometryIsInside: geometryIsInside
            case .UTL_getPlatformVersion: getPlatformVersion
            case .UTL_parseMapClientUrl: parseMapClientUrl
            case .UTL_pointAngleBetween: pointAngleBetween
            case .UTL_pointDistanceTo: pointDistanceTo
            case .UTL_polygonDistToClosestEdge: polygonDistToClosestEdge
            case .UTL_setAutomatedZoomLimit: setAutomatedZoomLimit
            case .UTL_setCollisionHandling: setCollisionHandling
            case .UTL_setEnableClustering: setEnableClustering
            case .UTL_setExtrusionOpacity: setExtrusionOpacity
            case .UTL_setLocationSettings: setLocationSettings
            case .UTL_setTypeLocationSettingsSelectable: setTypeLocationSettings
            case .UTL_setWallOpacity: setWallOpacity
            case .UTL_venueHasGraph: venueHasGraph
            }

            runner(arguments, mapsIndoorsData, result)
        }

        func getPlatformVersion(arguments _: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            result("iOS " + UIDevice.current.systemVersion)
        }

        func venueHasGraph(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            Task {
                guard let args = arguments else {
                    result(FlutterError(code: "venueHasGraph called without arguments", message: "UTL_venueHasGraph", details: nil))
                    return
                }

                guard let venueId = args["id"] as? String else {
                    result(FlutterError(code: "Could not read arguments", message: "UTL_venueHasGraph", details: nil))
                    return
                }

                let venue = await MPMapsIndoors.shared.venueWith(id: venueId)
                result(venue?.hasGraph)
            }
        }

        func pointAngleBetween(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "pointAngleBetween called without arguments", message: "UTL_pointAngleBetween", details: nil))
                return
            }

            guard let it = args["it"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_pointAngleBetween", details: nil))
                return
            }

            guard let other = args["other"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_pointAngleBetween", details: nil))
                return
            }

            let decoder = JSONDecoder()
            let fromPoint = try! decoder.decode(MPPoint.self, from: Data(it.utf8))
            let toPoint = try! decoder.decode(MPPoint.self, from: Data(other.utf8))

            let fromCoordinate = fromPoint.coordinate
            let toCoordinate = toPoint.coordinate

            let angle = MPGeometryUtils.bearingBetweenPoints(from: fromCoordinate, to: toCoordinate)
            result(angle)
        }

        func pointDistanceTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "pointDistanceTo called without arguments", message: "UTL_pointDistanceTo", details: nil))
                return
            }

            guard let it = args["it"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_pointDistanceTo", details: nil))
                return
            }

            guard let other = args["other"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_pointDistanceTo", details: nil))
                return
            }

            let decoder = JSONDecoder()
            let itObj = try! decoder.decode(MPPoint.self, from: Data(it.utf8))
            let otherObj = try! decoder.decode(MPPoint.self, from: Data(other.utf8))

            let distance = itObj.distanceTo(otherObj)
            result(distance)
        }

        func geometryIsInside(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "geometryIsInside called without arguments", message: "UTL_geometryIsInside", details: nil))
                return
            }

            guard let geo = args["it"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_geometryIsInside", details: nil))
                return
            }

            guard let point = args["point"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_geometryIsInside", details: nil))
                return
            }

            guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point.utf8)) as MPPoint else {
                result(FlutterError(code: "Could not parse point", message: "UTL_geometryIsInside", details: nil))
                return
            }

            guard let geom = try? JSONDecoder().decode(MPGeometry.self, from: Data(geo.utf8)) as MPGeometry else {
                result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryIsInside", details: nil))
                return
            }

            // Determine of the point is inside the polygon
            if geom is MPPolygonGeometry {
                let poly = geom.mp_polygon
                result(poly?.containsCoordinate(it.coordinate))
            } else if geom is MPMultiPolygonGeometry {
                let multiPoly = geom.mp_multiPolygon
                result(multiPoly?.containsCoordinate(it.coordinate))
            } else {
                result(FlutterError(code: "The given geometry needs to be a polygon", message: "UTL_geometryIsInside", details: nil))
            }
        }

        func geometryArea(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "parseMapClientUrl called without arguments", message: "UTL_geometryArea", details: nil))
                return
            }

            guard let geo = args["geometry"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_geometryArea", details: nil))
                return
            }

            let decoder = JSONDecoder()
            let geoObj = try! decoder.decode(MPGeometry.self, from: Data(geo.utf8))

            if geoObj is MPPoint {
                result(0)
                return
            }
            if geoObj is MPPolygonGeometry {
                result(geoObj.mp_polygon?.area)
                return
            }

            result(nil)
        }

        func polygonDistToClosestEdge(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "parseMapClientUrl called without arguments", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            guard let pointJson = args["point"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            guard let geo = args["it"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            let decoder = JSONDecoder()
            let geoObj = try! decoder.decode(MPGeometry.self, from: Data(geo.utf8))
            if !(geoObj is MPPolygonGeometry) {
                result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
            }

            let point = try! decoder.decode(MPPoint.self, from: Data(pointJson.utf8))
            let geoPoint = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

            if geoObj is MPPolygonGeometry {
                guard let outerRing = (geoObj.mp_polygon.coordinates.first?.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) else {
                    result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
                    return
                }

                var shortestDistance = Double.greatestFiniteMagnitude
                for i in 1 ..< outerRing.count {
                    let p1 = outerRing[i - 1]
                    let p2 = outerRing[i]

                    let distanceToLine = MPGeometryUtils.distancePointToLine(point: geoPoint, lineStart: p1, lineEnd: p2)
                    if distanceToLine < shortestDistance {
                        shortestDistance = distanceToLine
                    }
                }

                result(shortestDistance)
                return
            }
            result(nil)
        }

        func parseMapClientUrl(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "parseMapClientUrl called without arguments", message: "UTL_parseMapClientUrl", details: nil))
                return
            }

            guard let venueId = args["venueId"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_parseMapClientUrl", details: nil))
                return
            }

            guard let locationId = args["locationId"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_parseMapClientUrl", details: nil))
                return
            }

            result(MPMapsIndoors.shared.solution?.getMapClientUrlFor(venueId: venueId, locationId: locationId))
            result(nil)
        }

        func setCollisionHandling(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setCollisionHandling called without arguments", message: "UTL_setCollisionHandling", details: nil))
                return
            }

            guard let handling = args["handling"] as? Int else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_setCollisionHandling", details: nil))
                return
            }

            switch handling {
            case 0:
                MPMapsIndoors.shared.solution?.config.collisionHandling = .allowOverLap
            case 1:
                MPMapsIndoors.shared.solution?.config.collisionHandling = .removeLabelFirst
            case 2:
                MPMapsIndoors.shared.solution?.config.collisionHandling = .removeIconFirst
            case 3:
                MPMapsIndoors.shared.solution?.config.collisionHandling = .removeIconAndLabel
            default:
                break
            }

            result(nil)
        }

        func setEnableClustering(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setEnableClustering called without arguments", message: "UTL_setEnableClustering", details: nil))
                return
            }

            guard let enable = args["enable"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_setEnableClustering", details: nil))
                return
            }

            MPMapsIndoors.shared.solution?.config.enableClustering = enable == "true"
            result(nil)
        }

        func setExtrusionOpacity(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setExtrusionOpacity called without arguments", message: nil, details: nil))
                return
            }

            guard let opacity = args["opacity"] as? Double else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_setExtrusionOpacity", details: nil))
                return
            }

            MPMapsIndoors.shared.solution?.config.settings3D.extrusionOpacity = opacity
            result(nil)
        }

        func setWallOpacity(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setWallOpacity called without arguments", message: "UTL_setWallOpacity", details: nil))
                return
            }

            guard let opacity = args["opacity"] as? Double else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_setWallOpacity", details: nil))
                return
            }

            MPMapsIndoors.shared.solution?.config.settings3D.wallOpacity = opacity
            result(nil)
        }

        func setLocationSettings(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setLocationSettings called without arguments", message: Methods.UTL_setLocationSettings.rawValue, details: nil))
                return
            }

            guard let settings = args["locationSettings"] as? String else {
                result(FlutterError(code: "Could not read locationSettings", message: Methods.UTL_setLocationSettings.rawValue, details: nil))
                return
            }

            let decoder = JSONDecoder()
            do {
                let locationSettings = try decoder.decode(MPLocationSettings.self, from: Data(settings.utf8))

                MPMapsIndoors.shared.solution?.config.locationSettings = locationSettings
                result(nil)
            } catch {
                result(FlutterError(code: "Could not parse location settings", message: Methods.UTL_setLocationSettings.rawValue, details: nil))
            }
        }

        func setTypeLocationSettings(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setTypeLocationSettingsSelectable called without arguments", message: Methods.UTL_setTypeLocationSettingsSelectable.rawValue, details: nil))
                return
            }
            guard let typeName = args["name"] as? String else {
                result(FlutterError(code: "Could not find type argument", message: Methods.UTL_setTypeLocationSettingsSelectable.rawValue, details: nil))
                return
            }
            guard let settings = args["settings"] as? String else {
                result(FlutterError(code: "Could not read type location settings", message: Methods.UTL_setTypeLocationSettingsSelectable.rawValue, details: nil))
                return
            }

            let decoder = JSONDecoder()
            do {
                let locationSettings = try decoder.decode(MPLocationSettings.self, from: Data(settings.utf8))
                MPMapsIndoors.shared.solution?.types.first { $0.name == typeName }?.locationSettings = locationSettings
                result(nil)
            } catch {
                result(FlutterError(code: "Could not parse location settings", message: Methods.UTL_setTypeLocationSettingsSelectable.rawValue, details: nil))
            }
        }

        func setAutomatedZoomLimit(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "setAutomatedZoomLimit called without arguments", message: Methods.UTL_setAutomatedZoomLimit.rawValue, details: nil))
                return
            }
            guard let limit = args["limit"] as? Double else {
                result(FlutterError(code: "Could not read limit", message: Methods.UTL_setAutomatedZoomLimit.rawValue, details: nil))
                return
            }

            MPMapsIndoors.shared.solution?.config.automatedZoomLimit = limit
            result(nil)
        }
    }
}
