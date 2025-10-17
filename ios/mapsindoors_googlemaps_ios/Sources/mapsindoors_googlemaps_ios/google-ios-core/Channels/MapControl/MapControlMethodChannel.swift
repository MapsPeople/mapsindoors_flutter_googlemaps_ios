//
//  MapControlMethodChannel.swift
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

public class MapControlMethodChannel: NSObject {
    enum Methods: String {
        case MPC_selectFloor
        case MPC_clearFilter
        case MPC_deSelectLocation
        case MPC_getCurrentBuilding
        case MPC_getCurrentBuildingFloor
        case MPC_getCurrentFloorIndex
        case MPC_setFloorSelector
        case MPC_getCurrentMapsIndoorsZoom
        case MPC_getCurrentVenue
        case MPC_getMapStyle
        case MPC_getMapViewPaddingBottom
        case MPC_getMapViewPaddingEnd
        case MPC_getMapViewPaddingStart
        case MPC_getMapViewPaddingTop
        case MPC_goTo
        case MPC_hideFloorSelector
        case MPC_isFloorSelectorHidden
        case MPC_isUserPositionShown
        case MPC_selectBuilding
        case MPC_selectLocation
        case MPC_selectLocationById
        case MPC_selectVenue
        case MPC_setFilter
        case MPC_setFilterWithLocations
        case MPC_setMapPadding
        case MPC_setMapStyle
        case MPC_showInfoWindowOnClickedLocation
        case MPC_showUserPosition
        case MPC_enableLiveData
        case MPC_disableLiveData
        case MPC_moveCamera
        case MPC_animateCamera
        case MPC_getCurrentCameraPosition
        case MPC_setLabelOptions
        case MPC_clearHighlight
        case MPC_setHighlight
        case MPC_getBuildingSelectionMode
        case MPC_getFloorSelectionMode
        case MPC_setBuildingSelectionMode
        case MPC_setFloorSelectionMode
        case MPC_getHiddenFeatures
        case MPC_setHiddenFeatures
        case MPC_showCompassOnRotate

        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void = switch self {
            case .MPC_selectFloor: selectFloor
            case .MPC_clearFilter: clearFilter
            case .MPC_deSelectLocation: deSelectLocation
            case .MPC_getCurrentBuilding: getCurrentBuilding
            case .MPC_getCurrentBuildingFloor: getCurrentBuildingFloor
            case .MPC_getCurrentFloorIndex: getCurrentFloorIndex
            case .MPC_setFloorSelector: setFloorSelector
            case .MPC_getCurrentMapsIndoorsZoom: getCurrentMapsIndoorsZoom
            case .MPC_getCurrentVenue: getCurrentVenue
            case .MPC_getMapStyle: getMapStyle
            case .MPC_getMapViewPaddingBottom: getMapViewPaddingBottom
            case .MPC_getMapViewPaddingEnd: getMapViewPaddingEnd
            case .MPC_getMapViewPaddingStart: getMapViewPaddingStart
            case .MPC_getMapViewPaddingTop: getMapViewPaddingTop
            case .MPC_goTo: goTo
            case .MPC_hideFloorSelector: hideFloorSelector
            case .MPC_isFloorSelectorHidden: isFloorSelectorHidden
            case .MPC_isUserPositionShown: isUserPositionShown
            case .MPC_selectBuilding: selectBuilding
            case .MPC_selectLocation: selectLocation
            case .MPC_selectLocationById: selectLocationById
            case .MPC_selectVenue: selectVenue
            case .MPC_setFilter: setFilter
            case .MPC_setFilterWithLocations: setFilterWithLocations
            case .MPC_setMapPadding: setMapPadding
            case .MPC_setMapStyle: setMapStyle
            case .MPC_showInfoWindowOnClickedLocation: showInfoWindowOnClickedLocation
            case .MPC_showUserPosition: showUserPosition
            case .MPC_enableLiveData: enableLiveData
            case .MPC_disableLiveData: disableLiveData
            case .MPC_moveCamera: moveCamera
            case .MPC_animateCamera: moveCamera
            case .MPC_getCurrentCameraPosition: getCurrentCameraPosition
            case .MPC_setLabelOptions: setLabelOptions
            case .MPC_clearHighlight: clearHighlight
            case .MPC_setHighlight: setHighlight
            case .MPC_getBuildingSelectionMode: getBuildingSelectionMode
            case .MPC_getFloorSelectionMode: getFloorSelectionMode
            case .MPC_setBuildingSelectionMode: setBuildingSelectionMode
            case .MPC_setFloorSelectionMode: setFloorSelectionMode
            case .MPC_getHiddenFeatures: getHiddenFeatures
            case .MPC_setHiddenFeatures: setHiddenFeatures
            case .MPC_showCompassOnRotate: showCompassOnRotate
            }

            runner(arguments, mapsIndoorsData, result)
        }

        func selectFloor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let floorIndex = arguments?["floorIndex"] as? Int else {
                result(FlutterError(code: "Could not read floorIndex", message: "MPC_selectFloor", details: nil))
                return
            }

            mapsIndoorsData.mapControl?.select(floorIndex: floorIndex)
            result(nil)
        }

        func clearFilter(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            mapsIndoorsData.mapControl?.clearFilter()
            result(nil)
        }

        func deSelectLocation(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            mapsIndoorsData.mapControl?.select(location: nil, behavior: MPSelectionBehavior())
            result(nil)
        }

        func getCurrentBuilding(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let currentBuilding = mapsIndoorsData.mapControl?.currentBuilding else {
                result(nil)
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(MPBuildingCodable(withBuilding: currentBuilding))
                let resultJson = String(data: jsonData, encoding: String.Encoding.utf8)
                result(resultJson)
            } catch {
                result(FlutterError(code: "Could not encode building", message: "MPC_getCurrentBuilding", details: nil))
            }
        }

        func getCurrentBuildingFloor(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let currentFloorIndex = mapsIndoorsData.mapControl?.currentFloorIndex else {
                result(nil)
                return
            }

            guard let currentFloor = mapsIndoorsData.mapControl?.currentBuilding?.floors?[String(currentFloorIndex)] else {
                result(FlutterError(code: "Could not find currentFloor", message: "MPC_getCurrentBuildingFloor", details: nil))
                return
            }

            let floorCodable = MPFloorCodable(withFloor: currentFloor)

            do {
                let jsonData = try JSONEncoder().encode(floorCodable)
                let resultJson = String(data: jsonData, encoding: String.Encoding.utf8)
                result(resultJson)
            } catch {
                result(FlutterError(code: "Could not encode floor", message: "MPC_getCurrentBuildingFloor", details: nil))
            }
        }

        func getCurrentFloorIndex(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let currentFloorIndex = mapsIndoorsData.mapControl?.currentFloorIndex else {
                result(FlutterError(code: "Could not find currentFloor", message: nil, details: nil))
                return
            }
            result(currentFloorIndex)
        }

        func setFloorSelector(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let isAutoFloorChangeEnabled = arguments?["isAutoFloorChangeEnabled"] as? Bool else {
                result(FlutterError(code: "Could not read isAutoFloorChangeEnabled", message: "MPC_setFloorSelector", details: nil))
                return
            }

            if let floorSelectorChannel = mapsIndoorsData.mapControlFloorSelector {
                mapsIndoorsData.floorSelector = CustomFloorSelector(isAutoFloorChangeEnabled: isAutoFloorChangeEnabled, methodChannel: floorSelectorChannel)
                mapsIndoorsData.mapControl?.floorSelector = mapsIndoorsData.floorSelector
            }

            result(nil)
        }

        func getCurrentMapsIndoorsZoom(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let currentZoom = mapsIndoorsData.mapControl?.cameraPosition.zoom else {
                result(FlutterError(code: "Could not find currentZoom", message: "MPC_getCurrentMapsIndoorsZoom", details: nil))
                return
            }
            result(currentZoom)
        }

        func getCurrentVenue(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let currentVenue = mapsIndoorsData.mapControl?.currentVenue else {
                result(nil)
                return
            }
            do {
                let jsonData = try JSONEncoder().encode(MPVenueCodable(withVenue: currentVenue))
                let resultJson = String(data: jsonData, encoding: String.Encoding.utf8)
                result(resultJson)
            } catch {
                result(FlutterError(code: "Could not encode currentVenue", message: "MPC_getCurrentVenue", details: nil))
            }
        }

        func getMapStyle(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            var mapStyle = mapsIndoorsData.mapControl?.mapStyle
            // If the mapstyle is not set, use the default style for the current venue instead
            if mapStyle == nil {
                guard let currentVenue = mapsIndoorsData.mapControl?.currentVenue else {
                    result(nil)
                    return
                }
                mapStyle = currentVenue.defaultStyle
                if mapStyle == nil {
                    result(nil)
                    return
                }
            }

            do {
                let jsonData = try JSONEncoder().encode(MPMapStyleCodable(withMapStyle: mapStyle!))
                let resultJson = String(data: jsonData, encoding: String.Encoding.utf8)
                result(resultJson)
            } catch {
                result(FlutterError(code: "Could not encode mapStyle", message: "MPC_getMapStyle", details: nil))
            }
        }

        func getMapViewPaddingBottom(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let bottom = NSNumber(value: Float(mapsIndoorsData.mapControl?.mapPadding.bottom ?? 0.0))
            result(Int(truncating: bottom))
        }

        func getMapViewPaddingEnd(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let end = NSNumber(value: Float(mapsIndoorsData.mapControl?.mapPadding.right ?? 0.0))
            result(Int(truncating: end))
        }

        func getMapViewPaddingStart(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let start = NSNumber(value: Float(mapsIndoorsData.mapControl?.mapPadding.left ?? 0.0))
            result(Int(truncating: start))
        }

        func getMapViewPaddingTop(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let top = NSNumber(value: Float(mapsIndoorsData.mapControl?.mapPadding.top ?? 0.0))
            result(Int(truncating: top))
        }

        func goTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let entityJson = arguments?["entity"] as? String else {
                result(nil)
                return
            }

            guard let type = arguments?["type"] as? String else {
                result(FlutterError(code: "Could not read type", message: "MPC_goTo", details: nil))
                return
            }

            var entity: MPEntity

            switch type {
            case "MPLocation":
                guard let locationId = try? JSONDecoder().decode(MPLocationIdCodable.self, from: entityJson.data(using: .utf8)!) else {
                    result(FlutterError(code: "Could not parse entity as a location", message: "MPC_goTo", details: nil))
                    return
                }
                guard let location = MPMapsIndoors.shared.locationWith(locationId: locationId.id) else {
                    result(FlutterError(code: "Could find location with id", message: "MPC_goTo", details: nil))
                    return
                }
                entity = location
            case "MPFloor":
                guard let floor = try? JSONDecoder().decode(MPFloorCodable.self, from: entityJson.data(using: .utf8)!) else {
                    result(FlutterError(code: "Could not parse entity as a floor", message: "MPC_goTo", details: nil))
                    return
                }
                entity = floor

            case "MPBuilding":
                guard let building = try? JSONDecoder().decode(MPBuildingCodable.self, from: entityJson.data(using: .utf8)!) else {
                    result(FlutterError(code: "Could not parse entity as a building", message: "MPC_goTo", details: nil))
                    return
                }
                entity = building

            case "MPVenue":
                guard let venue = try? JSONDecoder().decode(MPVenueCodable.self, from: entityJson.data(using: .utf8)!) else {
                    result(FlutterError(code: "Could not parse venue", message: "MPC_goTo", details: nil))
                    return
                }
                entity = venue

            default:
                result(FlutterError(code: "Unknown type", message: "MPC_goTo", details: nil))
                return
            }

            if let maxZoom = arguments?["maxZoom"] as? Double {
                mapsIndoorsData.mapControl?.goTo(entity: MPEntityCodable(withEntity: entity), maxZoom: maxZoom)
            } else {
                mapsIndoorsData.mapControl?.goTo(entity: MPEntityCodable(withEntity: entity))
            }
            result(nil)
        }

        func hideFloorSelector(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let hide = arguments?["hide"] as? Bool else {
                result(nil)
                return
            }

            mapsIndoorsData.mapControl?.hideFloorSelector = hide
            result(nil)
        }

        func isFloorSelectorHidden(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let mapControl = mapsIndoorsData.mapControl else {
                result(FlutterError(code: "No existing mapcontrol", message: "MPC_isFloorSelectorHidden", details: nil))
                return
            }

            result(mapControl.hideFloorSelector)
        }

        func isUserPositionShown(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            result(mapsIndoorsData.mapControl?.showUserPosition)
        }

        func selectBuilding(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            Task {
                guard let buildingJson = arguments?["building"] as? String else {
                    result(FlutterError(code: "Could not read building", message: "MPC_selectBuilding", details: nil))
                    return
                }

                guard let moveCamera = arguments?["moveCamera"] as? Bool else {
                    result(FlutterError(code: "Could not read moveCamera", message: "MPC_selectBuilding", details: nil))
                    return
                }

                var buildingId: String?
                do {
                    if let json = try JSONSerialization.jsonObject(with: Data(buildingJson.utf8), options: []) as? [String: Any] {
                        buildingId = json["id"] as! String?
                    }
                } catch {
                    result(FlutterError(code: "Could not read building id", message: "MPC_selectBuilding", details: nil))
                    return
                }

                // Create a selectionBehavior with the moveCamera set as desired
                let selectionBehavior = MPSelectionBehavior()
                selectionBehavior.moveCamera = moveCamera

                // Find the building if possible
                guard let building = await MPMapsIndoors.shared.buildingWith(id: buildingId!) else {
                    result(FlutterError(code: "Could not find a building with the given buildingId", message: "MPC_selectBuilding", details: nil))
                    return
                }

                DispatchQueue.main.async {
                    mapsIndoorsData.mapControl?.select(building: building, behavior: selectionBehavior)
                }
                result(nil)
            }
        }

        func selectLocation(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let LocationId = arguments?["location"] as? String else {
                result(nil)
                return
            }

            guard let behaviorJson = arguments?["behavior"] as? String else {
                result(FlutterError(code: "Could not read behavior", message: "MPC_selectLocation", details: nil))
                return
            }

            let codeMsg = "Could not parse selectionBehavior"
            let messageMsg = "MPC_selectLocation"
            var selectionBehavior: MPSelectionBehavior
            do {
                selectionBehavior = try JSONDecoder().decode(MPSelectionBehavior.self, from: behaviorJson.data(using: .utf8)!)
            } catch DecodingError.dataCorrupted(let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.keyNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.typeMismatch(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.valueNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch {
                result(FlutterError(code: codeMsg, message: messageMsg, details: error.localizedDescription))
                return
            }
            if selectionBehavior.maxZoom == 999 {
                selectionBehavior.maxZoom = .nan
            }

            // Find the location if possible
            guard let location = MPMapsIndoors.shared.locationWith(locationId: LocationId) else {
                result(FlutterError(code: "Could not find a location with the given locationId", message: "MPC_selectLocation", details: nil))
                return
            }

            DispatchQueue.main.async {
                mapsIndoorsData.mapControl?.select(location: location, behavior: selectionBehavior)
            }
            result(nil)
        }

        func selectLocationById(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: String] else {
                result(FlutterError(code: "Could not read arguments", message: "MPC_selectLocationById", details: nil))
                return
            }

            guard let locationId = args["id"] else {
                result(FlutterError(code: "Could not read locationId", message: "MPC_selectLocationById", details: nil))
                return
            }

            guard let behaviorJson = args["behavior"] else {
                result(FlutterError(code: "Could not read behavior", message: "MPC_selectLocationById", details: nil))
                return
            }

            guard let selectionBehavior = try? JSONDecoder().decode(MPSelectionBehavior.self, from: behaviorJson.data(using: .utf8)!) else {
                result(FlutterError(code: "Could not parse behavior", message: "MPC_selectLocationById", details: nil))
                return
            }

            guard let location = MPMapsIndoors.shared.locationWith(locationId: locationId) else {
                result(FlutterError(code: "Could not find a location with the given locationId", message: "MPC_selectLocationById", details: nil))
                return
            }

            DispatchQueue.main.async {
                mapsIndoorsData.mapControl?.select(location: location, behavior: selectionBehavior)
            }

            result(nil)
        }

        func selectVenue(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let venueJson = arguments?["venue"] as? String else {
                result(FlutterError(code: "Could not read venue", message: "MPC_selectVenue", details: nil))
                return
            }

            guard let moveCamera = arguments?["moveCamera"] as? Bool else {
                result(FlutterError(code: "Could not read moveCamera", message: "MPC_selectVenue", details: nil))
                return
            }

            Task {
                var venueId: String?
                do {
                    if let json = try JSONSerialization.jsonObject(with: Data(venueJson.utf8), options: []) as? [String: Any] {
                        venueId = json["id"] as! String?
                    }
                } catch {
                    result(FlutterError(code: "Could not read venue id", message: "MPC_selectVenue", details: nil))
                    return
                }

                // Create a selectionBehavior
                let selectionBehavior = MPSelectionBehavior()
                selectionBehavior.moveCamera = moveCamera

                // Find the venue if possible
                guard let venue = await MPMapsIndoors.shared.venueWith(id: venueId!) else {
                    result(FlutterError(code: "Could not find a venue with the given venueId", message: "MPC_selectVenue", details: nil))
                    return
                }

                DispatchQueue.main.async {
                    mapsIndoorsData.mapControl?.select(venue: venue, behavior: selectionBehavior)
                }
            }
            result(nil)
        }

        func setFilter(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: String] else {
                result(FlutterError(code: "Could not read arguments", message: "MPC_setFilter", details: nil))
                return
            }

            guard let filterJson = args["filter"] else {
                result(FlutterError(code: "Could not read filter", message: "MPC_setFilter", details: nil))
                return
            }

            guard let behaviorJson = args["behavior"] else {
                result(FlutterError(code: "Could not read behavior", message: "MPC_setFilter", details: nil))
                return
            }

            guard let filter = try? JSONDecoder().decode(MPFilter.self, from: filterJson.data(using: .utf8)!) else {
                result(FlutterError(code: "Could not parse filter", message: "MPC_setFilter", details: nil))
                return
            }

            let codeMsg = "Could not parse filterBehavior"
            let messageMsg = "MPC_setFilter"
            var filterBehavior: MPFilterBehavior
            do {
                filterBehavior = try JSONDecoder().decode(MPFilterBehavior.self, from: behaviorJson.data(using: .utf8)!)
            } catch DecodingError.dataCorrupted(let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.keyNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.typeMismatch(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.valueNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch {
                result(FlutterError(code: codeMsg, message: messageMsg, details: error.localizedDescription))
                return
            }
            if filterBehavior.maxZoom == 999 {
                filterBehavior.maxZoom = .nan
            }

            mapsIndoorsData.mapControl?.setFilter(filter: filter, behavior: filterBehavior)
            result(nil)
        }

        func setFilterWithLocations(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let locationIds = arguments?["locations"] as? [String] else {
                result(FlutterError(code: "Could not read locations", message: "MPC_setFilterWithLocations", details: nil))
                return
            }

            guard let behaviorJson = arguments?["behavior"] as? String else {
                result(FlutterError(code: "Could not read behavior", message: "MPC_setFilterWithLocations", details: nil))
                return
            }

            guard let filterBehavior = try? JSONDecoder().decode(MPFilterBehavior.self, from: behaviorJson.data(using: .utf8)!) else {
                result(FlutterError(code: "Could not parse filterBehavior", message: "MPC_setFilterWithLocations", details: nil))
                return
            }

            let locations = locationIds.compactMap { MPMapsIndoors.shared.locationWith(locationId: $0) }
            mapsIndoorsData.mapControl?.setFilter(locations: locations, behavior: filterBehavior)
            result(nil)
        }

        func setMapPadding(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let start = arguments?["start"] as? Int else {
                result(FlutterError(code: "Could not read start", message: "MPC_setMapPadding", details: nil))
                return
            }
            guard let top = arguments?["top"] as? Int else {
                result(FlutterError(code: "Could not read top", message: "MPC_setMapPadding", details: nil))
                return
            }
            guard let end = arguments?["end"] as? Int else {
                result(FlutterError(code: "Could not read end", message: "MPC_setMapPadding", details: nil))
                return
            }
            guard let bottom = arguments?["bottom"] as? Int else {
                result(FlutterError(code: "Could not read bottom", message: "MPC_setMapPadding", details: nil))
                return
            }

            mapsIndoorsData.mapControl?.mapPadding.top = CGFloat(top)
            mapsIndoorsData.mapControl?.mapPadding.bottom = CGFloat(bottom)
            mapsIndoorsData.mapControl?.mapPadding.left = CGFloat(start)
            mapsIndoorsData.mapControl?.mapPadding.right = CGFloat(end)

            result(nil)
        }

        func setMapStyle(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: String] else {
                result(FlutterError(code: "Could not read arguments", message: "MPC_setMapStyle", details: nil))
                return
            }

            guard let mapStyleJson = args["mapStyle"] else {
                result(FlutterError(code: "Could not read mapStyle", message: "MPC_setMapStyle", details: nil))
                return
            }

            guard let mapStyle = try? JSONDecoder().decode(MPMapStyleCodable.self, from: mapStyleJson.data(using: .utf8)!) else {
                result(FlutterError(code: "Could not parse mapStyle", message: "MPC_setMapStyle", details: nil))
                return
            }

            mapsIndoorsData.mapControl?.mapStyle = mapStyle
            result(nil)
        }

        func showInfoWindowOnClickedLocation(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let show = arguments?["show"] as? Bool else {
                result(FlutterError(code: "Could not read show", message: "MPC_showInfoWindowOnClickedLocation", details: nil))
                return
            }

            mapsIndoorsData.mapControl?.showInfoWindowOnClickedLocation = show
            result(nil)
        }

        func showUserPosition(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let show = arguments?["show"] as? Bool else {
                result(FlutterError(code: "Could not read show", message: nil, details: nil))
                return
            }
            mapsIndoorsData.mapControl?.showUserPosition = show
            result(nil)
        }

        func enableLiveData(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let hasListener = arguments?["listener"] as? Bool else {
                result(FlutterError(code: "Could not read listener", message: "MPC_enableLiveData", details: nil))
                return
            }
            guard let domainType = arguments?["domainType"] as? String else {
                result(FlutterError(code: "Could not read domainType", message: "MPC_enableLiveData", details: nil))
                return
            }

            if hasListener {
                if mapsIndoorsData.liveDataDelegate == nil, mapsIndoorsData.mapControlMethodChannel != nil {
                    mapsIndoorsData.liveDataDelegate = MapControlLiveDataDelegate(methodChannel: mapsIndoorsData.mapControlMethodChannel!)
                }
                mapsIndoorsData.mapControl?.enableLiveData(domain: domainType, listener: { liveUpdate in
                    mapsIndoorsData.liveDataDelegate?.dataReceived(liveUpdate: liveUpdate)
                })
            } else {
                mapsIndoorsData.mapControl?.enableLiveData(domain: domainType, listener: nil)
            }
            result(nil)
        }

        func disableLiveData(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: String] else {
                result(FlutterError(code: "Could not read arguments", message: "MPC_disableLiveData", details: nil))
                return
            }

            guard let domainType = args["domainType"] else {
                result(FlutterError(code: "Could not read domainType", message: "MPC_disableLiveData", details: nil))
                return
            }
            mapsIndoorsData.mapControl?.disableLiveData(domain: domainType)
            result(nil)
        }

        func moveCamera(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let updateJson = arguments?["update"] as? String else {
                result(FlutterError(code: "Could not read update", message: "MPC_moveCamera", details: nil))
                return
            }

            guard let cameraUpdate = try? JSONDecoder().decode(CameraUpdate.self, from: updateJson.data(using: .utf8)!) else {
                result(FlutterError(code: "Could not parse cameraUpdate", message: "MPC_moveCamera", details: nil))
                return
            }

            do {
                let duration = arguments?["duration"] as? Int ?? 0
                try mapsIndoorsData.mapView?.animateCamera(cameraUpdate: cameraUpdate, duration: duration)
                result(nil)
            } catch {
                result(FlutterError(code: "Could not make camera update", message: "MPC_moveCamera", details: nil))
            }
        }

        func getCurrentCameraPosition(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let cameraPosition = mapsIndoorsData.mapControl?.cameraPosition else {
                result(FlutterError(code: "Could not read cameraPosition", message: "MPC_getCurrentCameraPosition", details: nil))
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(MPCameraPositionCodable(withCameraPosition: cameraPosition))
                let resultJson = String(data: jsonData, encoding: String.Encoding.utf8)
                result(resultJson)
            } catch {
                result(FlutterError(code: "Could not encode cameraPosition", message: "MPC_getCurrentCameraPosition", details: nil))
            }
        }

        func setLabelOptions(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let textSize = arguments?["textSize"] as? Int ?? -1

            let color = arguments?["color"] as? String ?? ""
            let textColor = UIColor(hex: color)

            guard let showHalo = arguments?["showHalo"] as? Bool else {
                result(FlutterError(code: "Could not read showHalo", message: "\(#function)", details: nil))
                return
            }
            let haloWidth: Float = showHalo ? 1.0 : 0.0
            let haloBlur: Float = showHalo ? 1.0 : 0.0
            let haloColor = UIColor.white

            if textSize != -1, let textColor {
                mapsIndoorsData.mapControl?.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(textSize)), textSize: Float(textSize), color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                result(nil)
                return
            }

            if let textColor {
                mapsIndoorsData.mapControl?.setMapLabelFont(color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                result(nil)
                return
            }

            if textSize != -1 {
                mapsIndoorsData.mapControl?.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(textSize)), textSize: Float(textSize), labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                result(nil)
                return
            }

            mapsIndoorsData.mapControl?.setMapLabelFont(labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)

            result(nil)
        }

        func clearHighlight(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            mapsIndoorsData.mapControl?.clearHighlight()
            result(nil)
        }

        func setHighlight(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments else {
                result(FlutterError(code: "Could not read arguments", message: "MPC_setHighlight", details: nil))
                return
            }
            guard let locationIds = args["locations"] as? [String] else {
                result(FlutterError(code: "Could not read locations", message: "MPC_setHighlight", details: nil))
                return
            }
            guard let behaviorJson = args["behavior"] as? String, let behaviorData = behaviorJson.data(using: .utf8) else {
                result(FlutterError(code: "Could not read behavior", message: "MPC_setHighlight", details: nil))
                return
            }

            let codeMsg = "Could not parse highlight behavior"
            let messageMsg = "MPC_setHighlight"
            var highlightBehavior: MPHighlightBehavior
            do {
                highlightBehavior = try JSONDecoder().decode(MPHighlightBehavior.self, from: behaviorData)
            } catch DecodingError.dataCorrupted(let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.keyNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.typeMismatch(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch DecodingError.valueNotFound(let type, let context) {
                result(FlutterError(code: codeMsg, message: messageMsg, details: context.debugDescription))
                return
            } catch {
                result(FlutterError(code: codeMsg, message: messageMsg, details: error.localizedDescription))
                return
            }
            if highlightBehavior.maxZoom == 999 {
                highlightBehavior.maxZoom = .nan
            }

            let locationsFilter = MPFilter()
            locationsFilter.locations = locationIds
            Task {
                let locations = await MPMapsIndoors.shared.locationsWith(query: MPQuery(), filter: locationsFilter)

                mapsIndoorsData.mapControl?.setHighlight(locations: locations, behavior: highlightBehavior)
            }
            result(nil)
        }

        func getBuildingSelectionMode(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let selectionMode = mapsIndoorsData.mapControl?.buildingSelectionMode else {
                result(nil)
                return
            }

            result(selectionMode.rawValue)
        }

        func getFloorSelectionMode(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let selectionMode = mapsIndoorsData.mapControl?.floorSelectionMode else {
                result(nil)
                return
            }

            result(selectionMode.rawValue)
        }

        func setBuildingSelectionMode(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            print("Called \(#function)")
            guard let args = arguments as? [String: Int] else {
                result(FlutterError(code: "Could not read arguments", message: Methods.MPC_setBuildingSelectionMode.rawValue, details: nil))
                return
            }

            guard let selectionMode = args["mode"] else {
                result(FlutterError(code: "Could not read building selection mode", message: Methods.MPC_setBuildingSelectionMode.rawValue, details: nil))
                return
            }

            mapsIndoorsData.mapControl?.buildingSelectionMode = MPSelectionMode(rawValue: selectionMode) ?? .automatic
            result(nil)
        }

        func setFloorSelectionMode(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: Int] else {
                result(FlutterError(code: "Could not read arguments", message: Methods.MPC_setFloorSelectionMode.rawValue, details: nil))
                return
            }

            guard let selectionMode = args["mode"] else {
                result(FlutterError(code: "Could not read floor selection mode", message: Methods.MPC_setFloorSelectionMode.rawValue, details: nil))
                return
            }

            mapsIndoorsData.mapControl?.floorSelectionMode = MPSelectionMode(rawValue: selectionMode) ?? .automatic
            result(nil)
        }

        func getHiddenFeatures(arguments _: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let hiddenFeatures = mapsIndoorsData.mapControl?.hiddenFeatures.compactMap({ MPFeatureType(rawValue: $0) }) else {
                result([])
                return
            }

            result(MPFeatureType.fixMapping(hiddenFeatures))
        }

        func setHiddenFeatures(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let args = arguments as? [String: [Int]] else {
                result(FlutterError(code: "Could not read arguments", message: Methods.MPC_setHiddenFeatures.rawValue, details: nil))
                return
            }

            guard let features = args["features"] else {
                result(FlutterError(code: "Could not read hiddenFeatures", message: Methods.MPC_setHiddenFeatures.rawValue, details: nil))
                return
            }

            mapsIndoorsData.mapControl?.hiddenFeatures = MPFeatureType.fixMapping(features)
            mapsIndoorsData.mapControl?.refresh()
            result(nil)
        }

        func showCompassOnRotate(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let show = arguments?["show"] as? Bool else {
                result(FlutterError(code: "Could not read show", message: nil, details: nil))
                return
            }
            do {
                try mapsIndoorsData.mapView?.showCompassOnRotate(show)
                result(nil)
            } catch {
                result(FlutterError(code: "Could not change showing of compass", message: "MPC_showCompassOnRotate", details: nil))
            }
        }
    }
}
