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

            // Decoding MPGeometry gives back the base class, never a subclass, so decode the GeoJSON
            // and build the concrete geometry, as polygonDistToClosestEdge does.
            guard let dto = try? JSONDecoder().decode(GeoJSONGeometry.self, from: Data(geo.utf8)) else {
                result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryIsInside", details: nil))
                return
            }

            switch dto.type {
            case GeoJSONGeometry.point:
                // A point contains only its own coordinate, which is what MPPoint.isInside checks on Android.
                guard let geomPoint = try? JSONDecoder().decode(MPPoint.self, from: Data(geo.utf8)) else {
                    result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryIsInside", details: nil))
                    return
                }
                result(geomPoint.coordinate.latitude == it.coordinate.latitude && geomPoint.coordinate.longitude == it.coordinate.longitude)
            case GeoJSONGeometry.polygon, GeoJSONGeometry.multiPolygon:
                guard let contained = dto.contains(it) else {
                    result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryIsInside", details: nil))
                    return
                }
                result(contained)
            default:
                result(FlutterError(code: "Unsupported geometry type: \(dto.type)", message: "UTL_geometryIsInside", details: nil))
            }
        }

        func geometryArea(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "geometryArea called without arguments", message: "UTL_geometryArea", details: nil))
                return
            }

            guard let geo = args["geometry"] as? String else {
                result(FlutterError(code: "Could not read arguments", message: "UTL_geometryArea", details: nil))
                return
            }

            guard let dto = try? JSONDecoder().decode(GeoJSONGeometry.self, from: Data(geo.utf8)) else {
                result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryArea", details: nil))
                return
            }

            // Dart answers MPPoint.area itself, so only the areal types reach this channel.
            guard dto.type == GeoJSONGeometry.polygon || dto.type == GeoJSONGeometry.multiPolygon else {
                result(FlutterError(code: "Unsupported geometry type: \(dto.type)", message: "UTL_geometryArea", details: nil))
                return
            }

            guard let polygons = dto.memberPolygons() else {
                result(FlutterError(code: "Could not parse geometry", message: "UTL_geometryArea", details: nil))
                return
            }

            // A MultiPolygon's area is the sum of its members' areas, as Android computes it.
            result(polygons.reduce(0.0) { $0 + $1.area })
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

            // Decoding MPGeometry gives back a base MPGeometry, never a subclass, and
            // mp_polygon is an internal NSObject-category property that nothing has set
            // on a freshly decoded object. So decode the GeoJSON rings ourselves and
            // build the concrete geometry, then use the SDK's own edge-distance method
            // (the same one the Android SDK exposes) rather than re-deriving it here.
            let decoder = JSONDecoder()

            guard let point = try? decoder.decode(MPPoint.self, from: Data(pointJson.utf8)) else {
                result(FlutterError(code: "Could not read point data", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            guard let dto = try? decoder.decode(GeoJSONGeometry.self, from: Data(geo.utf8)) else {
                result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            let polygons: [[[MPPoint]]]
            switch dto.type {
            case GeoJSONGeometry.polygon:
                guard let rings = dto.polygonRings else {
                    result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
                    return
                }
                polygons = [rings]
            case GeoJSONGeometry.multiPolygon:
                guard let multi = dto.multiPolygonRings else {
                    result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
                    return
                }
                polygons = multi
            default:
                result(FlutterError(code: "Unsupported geometry type: \(dto.type)", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            // A MultiPolygon's distance is the closest of its member polygons. The SDK
            // reports -1 when the point is outside a polygon's bounding box, so skip
            // those and only fall back to -1 when every member reports it.
            var shortestDistance = -1.0
            var constructedAny = false
            for rings in polygons {
                guard let polygon = MPPolygonGeometry(coordinates: rings) else { continue }
                constructedAny = true
                let d = polygon.squaredDistanceToClosestEdge(point)
                if d < 0 { continue }
                if shortestDistance < 0 || d < shortestDistance {
                    shortestDistance = d
                }
            }

            // -1 already means "the point is outside the bounding box", so it cannot also stand for
            // "nothing could be built from this input" - the caller would have no way to tell the two
            // apart. Android throws on the same input and replies with an error; match it.
            guard constructedAny else {
                result(FlutterError(code: "Could not read polygon data", message: "UTL_polygonDistToClosestEdge", details: nil))
                return
            }

            result(shortestDistance)
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

/// Minimal decoder for the GeoJSON geometry payloads the Dart layer sends:
/// `{"type": "Polygon" | "MultiPolygon", "coordinates": ..., "bbox": [...]}`. A `Point` decodes its
/// `type` only; its coordinates are read with `MPPoint` itself.
/// Coordinate pairs are `[longitude, latitude]`, per GeoJSON and the Dart
/// `MPGeometry` models. Needed because `MPGeometry` itself decodes to the base
/// class, so `JSONDecoder` can never hand back a concrete geometry subclass.
private struct GeoJSONGeometry: Decodable {
    static let point = "Point"
    static let polygon = "Polygon"
    static let multiPolygon = "MultiPolygon"

    let type: String
    /// Rings of a single polygon, when `type` is `Polygon`.
    let polygonRings: [[MPPoint]]?
    /// Rings per member polygon, when `type` is `MultiPolygon`.
    let multiPolygonRings: [[[MPPoint]]]?

    private enum CodingKeys: String, CodingKey {
        case type, coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        switch type {
        case Self.polygon:
            polygonRings = try container
                .decode([[[Double]]].self, forKey: .coordinates)
                .map(Self.points)
            multiPolygonRings = nil
        case Self.multiPolygon:
            polygonRings = nil
            multiPolygonRings = try container
                .decode([[[[Double]]]].self, forKey: .coordinates)
                .map { try $0.map(Self.points) }
        default:
            polygonRings = nil
            multiPolygonRings = nil
        }
    }

    /// Rings per member polygon: one member for a `Polygon`, one per member for a `MultiPolygon`,
    /// nil for any other type.
    private var memberRings: [[[MPPoint]]]? {
        polygonRings.map { [$0] } ?? multiPolygonRings
    }

    /// Builds one `MPPolygonGeometry` per member polygon. The SDK has no public initializer for
    /// `MPMultiPolygonGeometry`, so a MultiPolygon has to be handled through its members. Returns nil
    /// for any other type, or when a member cannot be built, since leaving that member out would give
    /// an answer for a geometry the caller never sent.
    func memberPolygons() -> [MPPolygonGeometry]? {
        guard let members = memberRings else { return nil }
        var polygons: [MPPolygonGeometry] = []
        for rings in members {
            guard let polygon = MPPolygonGeometry(coordinates: rings) else { return nil }
            polygons.append(polygon)
        }
        return polygons
    }

    /// Whether `point` is inside the geometry, or nil when it is not a polygon or a ring cannot be built.
    ///
    /// Each ring is tested as a polygon of its own: inside a member means inside its outer ring and in none of its holes, and inside the geometry means inside any member. That is how Android's `MPPolygonGeometry` and `MPMultiPolygonGeometry.isInside` answer, and it does not rely on the SDK's own hole handling, which changed in 4.21.0: up to 4.20.0 `containsCoordinate` counted a coordinate in a hole as inside whatever `ignorePolygonHoles` said.
    func contains(_ point: MPPoint) -> Bool? {
        guard let members = memberRings else { return nil }
        var inside = false
        for rings in members {
            var ringPolygons: [MPPolygonGeometry] = []
            for ring in rings {
                guard let ringPolygon = MPPolygonGeometry(coordinates: [ring]) else { return nil }
                ringPolygons.append(ringPolygon)
            }
            guard let outer = ringPolygons.first else { return nil }
            if outer.containsCoordinate(point.coordinate), !ringPolygons.dropFirst().contains(where: { $0.containsCoordinate(point.coordinate) }) {
                inside = true
            }
        }
        return inside
    }

    /// Throws rather than dropping a short coordinate pair. Skipping one silently turns a truncated
    /// ring into a shorter valid-looking one, and the caller then gets a distance to a polygon it
    /// never sent instead of being told its input was malformed.
    private static func points(_ ring: [[Double]]) throws -> [MPPoint] {
        try ring.map {
            guard $0.count >= 2 else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [CodingKeys.coordinates],
                        debugDescription: "A coordinate pair needs a longitude and a latitude, got \($0.count)"))
            }
            return MPPoint(latitude: $0[1], longitude: $0[0])
        }
    }
}
