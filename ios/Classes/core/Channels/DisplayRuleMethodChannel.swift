//
//  DisplayRuleMethodChannel.swift
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

public class DisplayRuleMethodChannel: NSObject {
    private static var refreshTimerWorkItem: DispatchWorkItem?
    
    enum Methods: String {
        case DRU_getBadgeFillColor
        case DRU_getBadgePosition
        case DRU_getBadgeRadius
        case DRU_getBadgeScale
        case DRU_getBadgeStrokeColor
        case DRU_getBadgeStrokeWidth
        case DRU_getBadgeZoomFrom
        case DRU_getBadgeZoomTo
        case DRU_getExtrusionColor
        case DRU_getExtrusionHeight
        case DRU_getExtrusionLightnessFactor
        case DRU_getExtrusionZoomFrom
        case DRU_getExtrusionZoomTo
        case DRU_getIconPlacement
        case DRU_getIconSize
        case DRU_getIconUrl
        case DRU_getLabel
        case DRU_getLabelMaxWidth
        case DRU_getLabelStyleBearing
        case DRU_getLabelStyleGraphic
        case DRU_getLabelStyleHaloBlur
        case DRU_getLabelStyleHaloColor
        case DRU_getLabelStyleHaloWidth
        case DRU_getLabelStyleTextColor
        case DRU_getLabelStyleTextOpacity
        case DRU_getLabelStyleTextSize
        case DRU_getLabelType
        case DRU_getLabelZoomFrom
        case DRU_getLabelZoomTo
        case DRU_getModel2DBearing
        case DRU_getModel2DHeightMeters
        case DRU_getModel2DModel
        case DRU_getModel2DWidthMeters
        case DRU_getModel2DZoomFrom
        case DRU_getModel2DZoomTo
        case DRU_getModel3DModel
        case DRU_getModel3DRotationX
        case DRU_getModel3DRotationY
        case DRU_getModel3DRotationZ
        case DRU_getModel3DScale
        case DRU_getModel3DZoomFrom
        case DRU_getModel3DZoomTo
        case DRU_getPolygonFillColor
        case DRU_getPolygonFillOpacity
        case DRU_getPolygonLightnessFactor
        case DRU_getPolygonStrokeColor
        case DRU_getPolygonStrokeOpacity
        case DRU_getPolygonStrokeWidth
        case DRU_getPolygonZoomFrom
        case DRU_getPolygonZoomTo
        case DRU_getWallColor
        case DRU_getWallHeight
        case DRU_getWallLightnessFactor
        case DRU_getWallZoomFrom
        case DRU_getWallZoomTo
        case DRU_getZoomFrom
        case DRU_getZoomTo
        case DRU_isBadgeVisible
        case DRU_isExtrusionVisible
        case DRU_isIconVisible
        case DRU_isLabelVisible
        case DRU_isModel2DVisible
        case DRU_isModel3DVisible
        case DRU_isPolygonVisible
        case DRU_isValid
        case DRU_isVisible
        case DRU_isWallVisible
        case DRU_reset
        case DRU_setBadgeFillColor
        case DRU_setBadgePosition
        case DRU_setBadgeRadius
        case DRU_setBadgeScale
        case DRU_setBadgeStrokeColor
        case DRU_setBadgeStrokeWidth
        case DRU_setBadgeVisible
        case DRU_setBadgeZoomFrom
        case DRU_setBadgeZoomTo
        case DRU_setExtrusionColor
        case DRU_setExtrusionHeight
        case DRU_setExtrusionLightnessFactor
        case DRU_setExtrusionVisible
        case DRU_setExtrusionZoomFrom
        case DRU_setExtrusionZoomTo
        case DRU_setIcon
        case DRU_setIconPlacement
        case DRU_setIconSize
        case DRU_setIconVisible
        case DRU_setLabel
        case DRU_setLabelMaxWidth
        case DRU_setLabelStyleBearing
        case DRU_setLabelStyleGraphic
        case DRU_setLabelStyleHaloBlur
        case DRU_setLabelStyleHaloColor
        case DRU_setLabelStyleHaloWidth
        case DRU_setLabelStyleTextColor
        case DRU_setLabelStyleTextOpacity
        case DRU_setLabelStyleTextSize
        case DRU_setLabelType
        case DRU_setLabelVisible
        case DRU_setLabelZoomFrom
        case DRU_setLabelZoomTo
        case DRU_setModel2DBearing
        case DRU_setModel2DHeightMeters
        case DRU_setModel2DModel
        case DRU_setModel2DVisible
        case DRU_setModel2DWidthMeters
        case DRU_setModel2DZoomFrom
        case DRU_setModel2DZoomTo
        case DRU_setModel3DModel
        case DRU_setModel3DRotationX
        case DRU_setModel3DRotationY
        case DRU_setModel3DRotationZ
        case DRU_setModel3DScale
        case DRU_setModel3DVisible
        case DRU_setModel3DZoomFrom
        case DRU_setModel3DZoomTo
        case DRU_setPolygonFillColor
        case DRU_setPolygonFillOpacity
        case DRU_setPolygonLightnessFactor
        case DRU_setPolygonStrokeColor
        case DRU_setPolygonStrokeOpacity
        case DRU_setPolygonStrokeWidth
        case DRU_setPolygonVisible
        case DRU_setPolygonZoomFrom
        case DRU_setPolygonZoomTo
        case DRU_setVisible
        case DRU_setWallColor
        case DRU_setWallHeight
        case DRU_setWallLightnessFactor
        case DRU_setWallVisible
        case DRU_setWallZoomFrom
        case DRU_setWallZoomTo
        case DRU_setZoomFrom
        case DRU_setZoomTo
        
        func call(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            let runner: (_ arguments: [String: Any]?, _ mapsIndoorsData: MapsIndoorsData, _ result: @escaping FlutterResult) -> Void
            
            switch self {
            case .DRU_getBadgeFillColor: runner = getBadgeFillColor
            case .DRU_getBadgePosition: runner = getBadgePosition
            case .DRU_getBadgeRadius: runner = getBadgeRadius
            case .DRU_getBadgeScale: runner = getBadgeScale
            case .DRU_getBadgeStrokeColor: runner = getBadgeStrokeColor
            case .DRU_getBadgeStrokeWidth: runner = getBadgeStrokeWidth
            case .DRU_getBadgeZoomFrom: runner = getBadgeZoomFrom
            case .DRU_getBadgeZoomTo: runner = getBadgeZoomTo
            case .DRU_getExtrusionColor: runner = getExtrusionColor
            case .DRU_getExtrusionHeight: runner = getExtrusionHeight
            case .DRU_getExtrusionLightnessFactor: runner = getExtrusionLightnessFactor
            case .DRU_getExtrusionZoomFrom: runner = getExtrusionZoomFrom
            case .DRU_getExtrusionZoomTo: runner = getExtrusionZoomTo
            case .DRU_getIconPlacement: runner = getIconPlacement
            case .DRU_getIconSize: runner = getIconSize
            case .DRU_getIconUrl: runner = getIconUrl
            case .DRU_getLabel: runner = getLabel
            case .DRU_getLabelMaxWidth: runner = getLabelMaxWidth
            case .DRU_getLabelStyleBearing: runner = getLabelStyleBearing
            case .DRU_getLabelStyleGraphic: runner = getLabelStyleGraphic
            case .DRU_getLabelStyleHaloBlur: runner = getLabelStyleHaloBlur
            case .DRU_getLabelStyleHaloColor: runner = getLabelStyleHaloColor
            case .DRU_getLabelStyleHaloWidth: runner = getLabelStyleHaloWidth
            case .DRU_getLabelStyleTextColor: runner = getLabelStyleTextColor
            case .DRU_getLabelStyleTextOpacity: runner = getLabelStyleTextOpacity
            case .DRU_getLabelStyleTextSize: runner = getLabelStyleTextSize
            case .DRU_getLabelType: runner = getLabelType
            case .DRU_getLabelZoomFrom: runner = getLabelZoomFrom
            case .DRU_getLabelZoomTo: runner = getLabelZoomTo
            case .DRU_getModel2DBearing: runner = getModel2DBearing
            case .DRU_getModel2DHeightMeters: runner = getModel2DHeightMeters
            case .DRU_getModel2DModel: runner = getModel2DModel
            case .DRU_getModel2DWidthMeters: runner = getModel2DWidthMeters
            case .DRU_getModel2DZoomFrom: runner = getModel2DZoomFrom
            case .DRU_getModel2DZoomTo: runner = getModel2DZoomTo
            case .DRU_getModel3DModel: runner = getModel3DModel
            case .DRU_getModel3DRotationX: runner = getModel3DRotationX
            case .DRU_getModel3DRotationY: runner = getModel3DRotationY
            case .DRU_getModel3DRotationZ: runner = getModel3DRotationZ
            case .DRU_getModel3DScale: runner = getModel3DScale
            case .DRU_getModel3DZoomFrom: runner = getModel3DZoomFrom
            case .DRU_getModel3DZoomTo: runner = getModel3DZoomTo
            case .DRU_getPolygonFillColor: runner = getPolygonFillColor
            case .DRU_getPolygonFillOpacity: runner = getPolygonFillOpacity
            case .DRU_getPolygonLightnessFactor: runner = getPolygonLightnessFactor
            case .DRU_getPolygonStrokeColor: runner = getPolygonStrokeColor
            case .DRU_getPolygonStrokeOpacity: runner = getPolygonStrokeOpacity
            case .DRU_getPolygonStrokeWidth: runner = getPolygonStrokeWidth
            case .DRU_getPolygonZoomFrom: runner = getPolygonZoomFrom
            case .DRU_getPolygonZoomTo: runner = getPolygonZoomTo
            case .DRU_getWallColor: runner = getWallColor
            case .DRU_getWallHeight: runner = getWallHeight
            case .DRU_getWallLightnessFactor: runner = getWallLightnessFactor
            case .DRU_getWallZoomFrom: runner = getWallZoomFrom
            case .DRU_getWallZoomTo: runner = getWallZoomTo
            case .DRU_getZoomFrom: runner = getZoomFrom
            case .DRU_getZoomTo: runner = getZoomTo
            case .DRU_isBadgeVisible: runner = isBadgeVisible
            case .DRU_isExtrusionVisible: runner = isExtrusionVisible
            case .DRU_isIconVisible: runner = isIconVisible
            case .DRU_isLabelVisible: runner = isLabelVisible
            case .DRU_isModel2DVisible: runner = isModel2DVisible
            case .DRU_isModel3DVisible: runner = isModel3DVisible
            case .DRU_isPolygonVisible: runner = isPolygonVisible
            case .DRU_isValid: runner = isValid
            case .DRU_isVisible: runner = isVisible
            case .DRU_isWallVisible: runner = isWallVisible
            case .DRU_reset: runner = reset
            case .DRU_setBadgeFillColor: runner = setBadgeFillColor
            case .DRU_setBadgePosition: runner = setBadgePosition
            case .DRU_setBadgeRadius: runner = setBadgeRadius
            case .DRU_setBadgeScale: runner = setBadgeScale
            case .DRU_setBadgeStrokeColor: runner = setBadgeStrokeColor
            case .DRU_setBadgeStrokeWidth: runner = setBadgeStrokeWidth
            case .DRU_setBadgeVisible: runner = setBadgeVisible
            case .DRU_setBadgeZoomFrom: runner = setBadgeZoomFrom
            case .DRU_setBadgeZoomTo: runner = setBadgeZoomTo
            case .DRU_setExtrusionColor: runner = setExtrusionColor
            case .DRU_setExtrusionHeight: runner = setExtrusionHeight
            case .DRU_setExtrusionLightnessFactor: runner = setExtrusionLightnessFactor
            case .DRU_setExtrusionVisible: runner = setExtrusionVisible
            case .DRU_setExtrusionZoomFrom: runner = setExtrusionZoomFrom
            case .DRU_setExtrusionZoomTo: runner = setExtrusionZoomTo
            case .DRU_setIcon: runner = setIcon
            case .DRU_setIconPlacement: runner = setIconPlacement
            case .DRU_setIconSize: runner = setIconSize
            case .DRU_setIconVisible: runner = setIconVisible
            case .DRU_setLabel: runner = setLabel
            case .DRU_setLabelMaxWidth: runner = setLabelMaxWidth
            case .DRU_setLabelStyleBearing: runner = setLabelStyleBearing
            case .DRU_setLabelStyleGraphic: runner = setLabelStyleGraphic
            case .DRU_setLabelStyleHaloBlur: runner = setLabelStyleHaloBlur
            case .DRU_setLabelStyleHaloColor: runner = setLabelStyleHaloColor
            case .DRU_setLabelStyleHaloWidth: runner = setLabelStyleHaloWidth
            case .DRU_setLabelStyleTextColor: runner = setLabelStyleTextColor
            case .DRU_setLabelStyleTextOpacity: runner = setLabelStyleTextOpacity
            case .DRU_setLabelStyleTextSize: runner = setLabelStyleTextSize
            case .DRU_setLabelType: runner = setLabelType
            case .DRU_setLabelVisible: runner = setLabelVisible
            case .DRU_setLabelZoomFrom: runner = setLabelZoomFrom
            case .DRU_setLabelZoomTo: runner = setLabelZoomTo
            case .DRU_setModel2DBearing: runner = setModel2DBearing
            case .DRU_setModel2DHeightMeters: runner = setModel2DHeightMeters
            case .DRU_setModel2DModel: runner = setModel2DModel
            case .DRU_setModel2DVisible: runner = setModel2DVisible
            case .DRU_setModel2DWidthMeters: runner = setModel2DWidthMeters
            case .DRU_setModel2DZoomFrom: runner = setModel2DZoomFrom
            case .DRU_setModel2DZoomTo: runner = setModel2DZoomTo
            case .DRU_setModel3DModel: runner = setModel3DModel
            case .DRU_setModel3DRotationX: runner = setModel3DRotationX
            case .DRU_setModel3DRotationY: runner = setModel3DRotationY
            case .DRU_setModel3DRotationZ: runner = setModel3DRotationZ
            case .DRU_setModel3DScale: runner = setModel3DScale
            case .DRU_setModel3DVisible: runner = setModel3DVisible
            case .DRU_setModel3DZoomFrom: runner = setModel3DZoomFrom
            case .DRU_setModel3DZoomTo: runner = setModel3DZoomTo
            case .DRU_setPolygonFillColor: runner = setPolygonFillColor
            case .DRU_setPolygonFillOpacity: runner = setPolygonFillOpacity
            case .DRU_setPolygonLightnessFactor: runner = setPolygonLightnessFactor
            case .DRU_setPolygonStrokeColor: runner = setPolygonStrokeColor
            case .DRU_setPolygonStrokeOpacity: runner = setPolygonStrokeOpacity
            case .DRU_setPolygonStrokeWidth: runner = setPolygonStrokeWidth
            case .DRU_setPolygonVisible: runner = setPolygonVisible
            case .DRU_setPolygonZoomFrom: runner = setPolygonZoomFrom
            case .DRU_setPolygonZoomTo: runner = setPolygonZoomTo
            case .DRU_setVisible: runner = setVisible
            case .DRU_setWallColor: runner = setWallColor
            case .DRU_setWallHeight: runner = setWallHeight
            case .DRU_setWallLightnessFactor: runner = setWallLightnessFactor
            case .DRU_setWallVisible: runner = setWallVisible
            case .DRU_setWallZoomFrom: runner = setWallZoomFrom
            case .DRU_setWallZoomTo: runner = setWallZoomTo
            case .DRU_setZoomFrom: runner = setZoomFrom
            case .DRU_setZoomTo: runner = setZoomTo
            }
            
            runner(arguments, mapsIndoorsData, result)
        }
        
        func getDisplayRule(id: String) -> MPDisplayRule? {
            if let location = MPMapsIndoors.shared.locationWith(locationId: id) {
                return MPMapsIndoors.shared.displayRuleFor(location: location)
            } else {
                if let displayRuleType = isSolutionDisplayRule(name: id) {
                    return MPMapsIndoors.shared.displayRuleFor(displayRuleType: displayRuleType)
                } else {
                    return MPMapsIndoors.shared.displayRuleFor(type: id)
                }
            }
        }
        
        func hexStringFromColor(color: UIColor) -> String {
            let components = color.cgColor.components
            let r: CGFloat = components?[0] ?? 0.0
            let g: CGFloat = components?[1] ?? 0.0
            let b: CGFloat = components?[2] ?? 0.0
            
            let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
            print(hexString)
            return hexString
        }
        
        func isSolutionDisplayRule(name: String) -> MPDisplayRuleType? {
            switch name {
            case "buildingOutline":
                return .buildingOutline
            case "selectionHighlight":
                return .selectionHighlight
            case "positionIndicator":
                return .blueDot
            case "main":
                return .main
            case "highlight":
                return .highlight
            case "selection":
                return .selection
            case "default":
                return .default
            default:
                return nil
            }
        }
        
        func isVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isVisible, result: result) else { return }
            result(displayRule.visible)
        }
        
        func setVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setVisible, result: result) else {
                return
            }
            displayRule.visible = value
            result(nil)
        }
        
        func getIconSize(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getIconSize, result: result) else { return }
            let data = try? JSONEncoder().encode(MPIconSizeCodable(withCGSize: displayRule.iconSize))
            guard let iconSizeData = data, let iconSizeString = String(data: iconSizeData, encoding: .utf8) else {
                result(FlutterError(code: "Failed to encode icon size", message: "DRU_getIconSize", details: nil))
                return
            }
            
            result(iconSizeString)
        }
        
        func getIconUrl(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getIconUrl, result: result) else { return }
            result(displayRule.iconURL?.absoluteString)
        }
        
        func getLabel(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabel, result: result) else { return }
            result(displayRule.label)
        }
        
        private func displayRuleFor(arguments: [String: Any]?, method: Methods, result: @escaping FlutterResult) -> MPDisplayRule? {
            guard let displayRuleId = arguments?["id"] as? String else {
                result(FlutterError(code: "Could not find id for DisplayRule", message: method.rawValue, details: nil))
                return nil
            }
            guard let displayRule = getDisplayRule(id: displayRuleId) else {
                result(FlutterError(code: "No DisplayRule existing for this Id", message: method.rawValue, details: nil))
                return nil
            }
            return displayRule
        }
        
        func getLabelMaxWidth(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelMaxWidth, result: result) else { return }
            result(displayRule.labelMaxWidth)
        }
        
        func getLabelZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelZoomFrom, result: result) else { return }
            result(displayRule.labelZoomFrom)
        }
        
        func getLabelZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelZoomTo, result: result) else { return }
            result(displayRule.labelZoomTo)
        }
        
        func getModel2DBearing(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DBearing, result: result) else { return }
            result(displayRule.model2DBearing)
        }
        
        func getModel2DHeightMeters(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DHeightMeters, result: result) else { return }
            result(displayRule.model2DHeightMeters)
        }
        
        func getModel2DModel(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DModel, result: result) else { return }
            result(displayRule.model2DModel)
        }
        
        func getModel2DZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DZoomTo, result: result) else { return }
            result(displayRule.model2DZoomTo)
        }
        
        func getModel2DWidthMeters(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DWidthMeters, result: result) else { return }
            result(displayRule.model2DWidthMeters)
        }
        
        func getModel2DZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel2DZoomFrom, result: result) else { return }
            result(displayRule.model2DZoomFrom)
        }
        
        func getPolygonFillColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonFillColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.polygonFillColor!))
        }
        
        func getPolygonFillOpacity(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonFillOpacity, result: result) else { return }
            result(displayRule.polygonFillOpacity)
        }
        
        func getPolygonZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonZoomTo, result: result) else { return }
            result(displayRule.polygonZoomTo)
        }
        
        func getPolygonStrokeColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonStrokeColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.polygonStrokeColor!))
        }
        
        func getPolygonStrokeOpacity(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonStrokeOpacity, result: result) else { return }
            result(displayRule.polygonStrokeOpacity)
        }
        
        func getPolygonStrokeWidth(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonStrokeWidth, result: result) else { return }
            result(displayRule.polygonStrokeWidth)
        }
        
        func getPolygonZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonZoomFrom, result: result) else { return }
            result(displayRule.polygonZoomFrom)
        }
        
        func getZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getZoomFrom, result: result) else { return }
            result(displayRule.zoomFrom)
        }
        
        func getZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getZoomTo, result: result) else { return }
            result(displayRule.zoomTo)
        }
        
        func isIconVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isIconVisible, result: result) else { return }
            result(displayRule.iconVisible)
        }
        
        func isLabelVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isLabelVisible, result: result) else { return }
            result(displayRule.labelVisible)
        }
        
        func isModel2DVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isModel2DVisible, result: result) else { return }
            result(displayRule.model2DVisible)
        }
        
        func isPolygonVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isPolygonVisible, result: result) else { return }
            result(displayRule.polygonVisible)
        }
        
        func isValid(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard displayRuleFor(arguments: arguments, method: .DRU_isValid, result: result) != nil else { return }
            result(true)
        }
        
        func reset(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRuleId = arguments?["id"] as? String else {
                result(FlutterError(code: "Could not find id for DisplayRule", message: "DRU_reset", details: nil))
                return
            }
            guard let displayRule = getDisplayRule(id: displayRuleId) else {
                result(FlutterError(code: "No DisplayRule existing for this Id", message: "DRU_reset", details: nil))
                return
            }
            
            displayRule.reset()
            result(nil)
        }
        
        func setIcon(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "url", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setIcon, result: result) else {
                return
            }
            displayRule.iconURL = URL(string: value)
            result(nil)
        }
        
        func setIconVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setIconVisible, result: result) else {
                return
            }
            displayRule.iconVisible = value
            result(nil)
        }
        
        func setIconSize(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "size", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setIconSize, result: result) else {
                return
            }
            guard let iconSize = try? JSONDecoder().decode(MPIconSizeCodable.self, from: Data(value.utf8)) else {
                result(FlutterError(code: "Could not parse iconSize", message: "DRU_setIconSize", details: nil))
                return
            }
            displayRule.iconSize = CGSize(width: iconSize.width!, height: iconSize.height!)
            result(nil)
        }
        
        func setLabel(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "label", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabel, result: result) else {
                return
            }
            displayRule.label = value
            result(nil)
        }
        
        func setLabelMaxWidth(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "maxWidth", type: UInt.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelMaxWidth, result: result) else {
                return
            }
            displayRule.labelMaxWidth = value
            result(nil)
        }
        
        func setLabelVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelVisible, result: result) else {
                return
            }
            displayRule.labelVisible = value
            result(nil)
        }
        
        func setLabelZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelZoomFrom, result: result) else {
                return
            }
            displayRule.labelZoomFrom = value
            result(nil)
        }
        
        func setLabelZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelZoomTo, result: result) else {
                return
            }
            displayRule.labelZoomTo = value
            result(nil)
        }
        
        func setModel2DBearing(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "bearing", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DBearing, result: result) else {
                return
            }
            displayRule.model2DBearing = value
            result(nil)
        }
        
        func setModel2DModel(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "model", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DModel, result: result) else {
                return
            }
            displayRule.model2DModel = value
            result(nil)
        }
        
        func setModel2DHeightMeters(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "height", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DHeightMeters, result: result) else {
                return
            }
            displayRule.model2DHeightMeters = value
            result(nil)
        }
        
        func setModel2DVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DVisible, result: result) else {
                return
            }
            displayRule.model2DVisible = value
            result(nil)
        }
        
        func setModel2DWidthMeters(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "width", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DWidthMeters, result: result) else {
                return
            }
            displayRule.model2DWidthMeters = value
            result(nil)
        }
        
        func setModel2DZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DZoomFrom, result: result) else {
                return
            }
            displayRule.model2DZoomFrom = value
            result(nil)
        }
        
        func setModel2DZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel2DZoomTo, result: result) else {
                return
            }
            displayRule.model2DZoomTo = value
            result(nil)
        }
        
        func setPolygonFillColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonFillColor, result: result) else {
                return
            }
            displayRule.polygonFillColor = UIColor(hex: value)
            result(nil)
        }
        
        func setPolygonFillOpacity(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "opacity", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonFillOpacity, result: result) else {
                return
            }
            displayRule.polygonFillOpacity = value
            result(nil)
        }
        
        func setPolygonStrokeColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonStrokeColor, result: result) else {
                return
            }
            displayRule.polygonStrokeColor = UIColor(hex: value)
            result(nil)
        }
        
        func setPolygonStrokeOpacity(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "opacity", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonStrokeOpacity, result: result) else {
                return
            }
            displayRule.polygonStrokeOpacity = value
            result(nil)
        }
        
        func setPolygonStrokeWidth(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "width", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonStrokeWidth, result: result) else {
                return
            }
            displayRule.polygonStrokeWidth = value
            result(nil)
        }
        
        func setPolygonVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonVisible, result: result) else {
                return
            }
            displayRule.polygonVisible = value
            result(nil)
        }
        
        func setPolygonZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonZoomFrom, result: result) else {
                return
            }
            displayRule.polygonZoomFrom = value
            result(nil)
        }
        
        func setPolygonZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonZoomTo, result: result) else {
                return
            }
            displayRule.polygonZoomTo = value
            result(nil)
        }
        
        func getExtrusionColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getExtrusionColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.extrusionColor!))
        }
        
        func getExtrusionHeight(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getExtrusionHeight, result: result) else { return }
            result(displayRule.extrusionHeight)
        }
        
        func getExtrusionZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getExtrusionZoomFrom, result: result) else { return }
            result(displayRule.extrusionZoomFrom)
        }
        
        func getExtrusionZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getExtrusionZoomTo, result: result) else { return }
            result(displayRule.extrusionZoomTo)
        }
        
        func getWallColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getWallColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.wallsColor!))
        }
        
        func getWallHeight(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getWallHeight, result: result) else { return }
            result(displayRule.wallsHeight)
        }
        
        func getWallZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getWallZoomFrom, result: result) else { return }
            result(displayRule.wallsZoomFrom)
        }
        
        func getWallZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getWallZoomTo, result: result) else { return }
            result(displayRule.wallsZoomTo)
        }
        
        func isExtrusionVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isExtrusionVisible, result: result) else { return }
            result(displayRule.extrusionVisible)
        }
        
        func isWallVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isWallVisible, result: result) else { return }
            result(displayRule.wallsVisible)
        }
        
        func setExtrusionColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionColor, result: result) else {
                return
            }
            displayRule.extrusionColor = UIColor(hex: value)
            result(nil)
        }
        
        func setExtrusionHeight(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "height", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionHeight, result: result) else {
                return
            }
            displayRule.extrusionHeight = value
            result(nil)
        }
        
        func setExtrusionVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionVisible, result: result) else {
                return
            }
            displayRule.extrusionVisible = value
            result(nil)
        }
        
        func setExtrusionZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionZoomFrom, result: result) else {
                return
            }
            displayRule.extrusionZoomFrom = value
            result(nil)
        }
        
        func setExtrusionZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionZoomTo, result: result) else {
                return
            }
            displayRule.extrusionZoomTo = value
            result(nil)
        }
        
        func setWallColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallColor, result: result) else {
                return
            }
            displayRule.wallsColor = UIColor(hex: value)
            result(nil)
        }
        
        func setWallHeight(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "height", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallHeight, result: result) else {
                return
            }
            displayRule.wallsHeight = value
            result(nil)
        }
        
        func setWallVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallVisible, result: result) else {
                return
            }
            displayRule.wallsVisible = value
            result(nil)
        }
        
        func setWallZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallZoomFrom, result: result) else {
                return
            }
            displayRule.wallsZoomFrom = value
            result(nil)
        }
        
        func setWallZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallZoomTo, result: result) else {
                return
            }
            displayRule.wallsZoomTo = value
            result(nil)
        }
        
        func setZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setZoomFrom, result: result) else {
                return
            }
            displayRule.zoomFrom = value
            result(nil)
        }
        
        func setZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setZoomTo, result: result) else {
                return
            }
            displayRule.zoomTo = value
            result(nil)
        }
        
        func getModel3DRotationX(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DRotationX, result: result) else { return }
            result(displayRule.model3DRotationX)
        }
        
        func getModel3DRotationY(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DRotationY, result: result) else { return }
            result(displayRule.model3DRotationY)
        }
        
        func getModel3DRotationZ(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DRotationZ, result: result) else { return }
            result(displayRule.model3DRotationZ)
        }
        
        func getModel3DModel(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DModel, result: result) else { return }
            result(displayRule.model3DModel)
        }
        
        func getModel3DScale(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DScale, result: result) else { return }
            result(displayRule.model3DScale)
        }
        
        func isModel3DVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isModel3DVisible, result: result) else { return }
            result(displayRule.model3DVisible)
        }
        
        func getModel3DZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DZoomFrom, result: result) else { return }
            result(displayRule.model3DZoomFrom)
        }
        
        func getModel3DZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getModel3DZoomTo, result: result) else { return }
            result(displayRule.model3DZoomTo)
        }
        
        func setModel3DModel(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "model", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DModel, result: result) else {
                return
            }
            displayRule.model3DModel = value
            result(nil)
        }
        
        func setModel3DRotationX(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "rotation", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DRotationX, result: result) else {
                return
            }
            displayRule.model3DRotationX = value
            result(nil)
        }
        
        func setModel3DRotationY(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "rotation", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DRotationY, result: result) else {
                return
            }
            displayRule.model3DRotationY = value
            result(nil)
        }
        
        func setModel3DRotationZ(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "rotation", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DRotationZ, result: result) else {
                return
            }
            displayRule.model3DRotationZ = value
            result(nil)
        }
        
        func setModel3DScale(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "scale", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DScale, result: result) else {
                return
            }
            displayRule.model3DScale = value
            result(nil)
        }
        
        func setModel3DVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DVisible, result: result) else {
                return
            }
            displayRule.model3DVisible = value
            result(nil)
        }
        
        func setModel3DZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DZoomFrom, result: result) else {
                return
            }
            displayRule.model3DZoomFrom = value
            result(nil)
        }
        
        func setModel3DZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setModel3DZoomTo, result: result) else {
                return
            }
            displayRule.model3DZoomTo = value
            result(nil)
        }
        
        func setBadgeFillColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeFillColor, result: result) else {
                return
            }
            displayRule.badgeFillColor = UIColor(hex: value)
            result(nil)
        }
        
        func setBadgePosition(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "position", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgePosition, result: result) else {
                return
            }
            displayRule.badgePosition = MPBadgePosition(rawValue: value)
            result(nil)
        }
        
        func setBadgeRadius(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "radius", type: Int.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeRadius, result: result) else {
                return
            }
            displayRule.badgeRadius = value
            result(nil)
        }
        
        func setBadgeScale(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "scale", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeScale, result: result) else {
                return
            }
            displayRule.badgeScale = value
            result(nil)
        }
        
        func setBadgeStrokeColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeStrokeColor, result: result) else {
                return
            }
            displayRule.badgeStrokeColor = UIColor(hex: value)
            result(nil)
        }
        
        func setBadgeStrokeWidth(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "width", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeStrokeWidth, result: result) else {
                return
            }
            displayRule.badgeStrokeWidth = value
            result(nil)
        }
        
        func setBadgeVisible(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "visible", type: Bool.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeVisible, result: result) else {
                return
            }
            displayRule.badgeVisible = value
            result(nil)
        }
        
        func setBadgeZoomFrom(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomFrom", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeZoomFrom, result: result) else {
                return
            }
            displayRule.badgeZoomFrom = value
            result(nil)
        }
        
        func setBadgeZoomTo(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "zoomTo", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setBadgeZoomTo, result: result) else {
                return
            }
            displayRule.badgeZoomTo = value
            result(nil)
        }
        
        func setExtrusionLightnessFactor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "factor", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setExtrusionLightnessFactor, result: result) else {
                return
            }
            displayRule.extrusionLightnessFactor = value
            result(nil)
        }
        
        func setIconPlacement(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "placement", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setIconPlacement, result: result) else {
                return
            }
            displayRule.iconPlacement = MPIconPlacement(rawValue: value)
            result(nil)
        }
        
        func setLabelStyleBearing(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "bearing", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleBearing, result: result) else {
                return
            }
            displayRule.labelStyleBearing = value
            result(nil)
        }
        
        func setLabelStyleHaloBlur(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "blur", type: Int.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleHaloBlur, result: result) else {
                return
            }
            displayRule.labelStyleHaloBlur = value
            result(nil)
        }
        
        func setLabelStyleHaloColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleHaloColor, result: result) else {
                return
            }
            displayRule.labelStyleHaloColor = UIColor(hex: value)
            result(nil)
        }
        
        func setLabelStyleHaloWidth(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "width", type: Int.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleHaloWidth, result: result) else {
                return
            }
            displayRule.labelStyleHaloWidth = value
            result(nil)
        }
        
        func setLabelStyleTextColor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "color", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleTextColor, result: result) else {
                return
            }
            displayRule.labelStyleTextColor = UIColor(hex: value)
            result(nil)
        }
        
        func setLabelStyleTextOpacity(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "opacity", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleTextOpacity, result: result) else {
                return
            }
            displayRule.labelStyleTextOpacity = value
            result(nil)
        }
        
        func setLabelStyleTextSize(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "size", type: Int.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleTextSize, result: result) else {
                return
            }
            displayRule.labelStyleTextSize = value
            result(nil)
        }
        
        func setLabelType(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "type", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelType, result: result) else {
                return
            }
            displayRule.labelType = MPLabelType(rawValue: value)
            result(nil)
        }
        
        func setPolygonLightnessFactor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "factor", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setPolygonLightnessFactor, result: result) else {
                return
            }
            displayRule.polygonLightnessFactor = value
            result(nil)
        }
        
        func setWallLightnessFactor(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, value) = displayRuleAndValueFor(property: "factor", type: Double.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setWallLightnessFactor, result: result) else {
                return
            }
            displayRule.wallsLightnessFactor = value
            result(nil)
        }
        
        private func displayRuleAndValueFor<T>(property: String, type _: T.Type, arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, method: Methods, result: @escaping FlutterResult) -> (MPDisplayRule, T)? {
            guard let displayRuleId = arguments?["id"] as? String else {
                result(FlutterError(code: "Could not find id for DisplayRule", message: "\(method)", details: nil))
                return nil
            }
            guard let displayRule = getDisplayRule(id: displayRuleId) else {
                result(FlutterError(code: "No DisplayRule existing for this Id", message: "\(method)", details: nil))
                return nil
            }
            guard let propertyValue = arguments?[property] as? T else {
                result(FlutterError(code: "Could not find value for setter", message: "\(method)", details: nil))
                return nil
            }
            
            setRefreshTimer(mapsIndoorsData)
            return (displayRule, propertyValue)
        }

        func setRefreshTimer(_ mapsIndoorsData: MapsIndoorsData) {
            refreshTimerWorkItem?.cancel()

            refreshTimerWorkItem = DispatchWorkItem {
                mapsIndoorsData.mapControl?.refresh()
            }
            
            if let refreshTimerWorkItem {
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: refreshTimerWorkItem)
            }
        }

        func getBadgeFillColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeFillColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.badgeFillColor!))
        }
        
        func getBadgePosition(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgePosition, result: result) else { return }
            let position = (displayRule.badgePosition ?? .topLeft).rawValue
            result(position)
        }
        
        func getBadgeRadius(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeRadius, result: result) else { return }
            result(displayRule.badgeRadius)
        }
        
        func getBadgeScale(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeScale, result: result) else { return }
            result(displayRule.badgeScale)
        }
        
        func getBadgeStrokeColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeStrokeColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.badgeStrokeColor!))
        }
        
        func getBadgeStrokeWidth(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeStrokeWidth, result: result) else { return }
            result(displayRule.badgeStrokeWidth)
        }
        
        func getBadgeZoomFrom(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeZoomFrom, result: result) else { return }
            result(displayRule.badgeZoomFrom)
        }
        
        func getBadgeZoomTo(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getBadgeZoomTo, result: result) else { return }
            result(displayRule.badgeZoomTo)
        }
        
        func getExtrusionLightnessFactor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getExtrusionLightnessFactor, result: result) else { return }
            result(displayRule.extrusionLightnessFactor)
        }
        
        func getIconPlacement(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getIconPlacement, result: result) else { return }
            result(displayRule.iconPlacement?.rawValue)
        }
        
        func getLabelStyleBearing(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleBearing, result: result) else { return }
            result(displayRule.labelStyleBearing)
        }
        
        func getLabelStyleHaloBlur(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleHaloBlur, result: result) else { return }
            result(displayRule.labelStyleHaloBlur)
        }
        
        func getLabelStyleHaloColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleHaloColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.labelStyleHaloColor!))
        }
        
        func getLabelStyleHaloWidth(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleHaloWidth, result: result) else { return }
            result(displayRule.labelStyleHaloWidth)
        }
        
        func getLabelStyleTextColor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleTextColor, result: result) else { return }
            result(hexStringFromColor(color: displayRule.labelStyleTextColor!))
        }
        
        func getLabelStyleTextOpacity(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleTextOpacity, result: result) else { return }
            result(displayRule.labelStyleTextOpacity)
        }
        
        func getLabelStyleTextSize(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleTextSize, result: result) else { return }
            result(displayRule.labelStyleTextSize)
        }
        
        func getLabelType(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelType, result: result) else { return }
            result(displayRule.labelType?.rawValue)
        }
        
        func getPolygonLightnessFactor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getPolygonLightnessFactor, result: result) else { return }
            result(displayRule.polygonLightnessFactor)
        }
        
        func getWallLightnessFactor(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getWallLightnessFactor, result: result) else { return }
            result(displayRule.wallsLightnessFactor)
        }
        
        func isBadgeVisible(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_isBadgeVisible, result: result) else { return }
            result(displayRule.badgeVisible)
        }
        
        func getLabelStyleGraphic(arguments: [String: Any]?, mapsIndoorsData _: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let displayRule = displayRuleFor(arguments: arguments, method: .DRU_getLabelStyleGraphic, result: result) else { return }
            let graphicLabel: [String: Any] = [
                "backgroundImage": displayRule.labelStyleGraphicBackgroundImage,
                "content": displayRule.labelStyleGraphicContent,
                "stretchX": displayRule.labelStyleGraphicStretchX,
                "stretchY": displayRule.labelStyleGraphicStretchY
            ]
            result(graphicLabel)
        }

        func setLabelStyleGraphic(arguments: [String: Any]?, mapsIndoorsData: MapsIndoorsData, result: @escaping FlutterResult) {
            guard let (displayRule, valueString) = displayRuleAndValueFor(property: "graphic", type: String.self, arguments: arguments, mapsIndoorsData: mapsIndoorsData, method: .DRU_setLabelStyleGraphic, result: result) else {
                return
            }
            
            guard let value = try? JSONDecoder().decode(MPLabelGraphic.self, from: Data(valueString.utf8)) else {
                result(FlutterError(code: "Could not parse MPLabelGraphic", message: Methods.DRU_setLabelStyleGraphic.rawValue, details: nil))
                return
            }

            displayRule.labelStyleGraphicBackgroundImage = value.backgroundImage
            displayRule.labelStyleGraphicContent = value.content
            displayRule.labelStyleGraphicStretchX = value.stretchX
            displayRule.labelStyleGraphicStretchY = value.stretchY

            result(nil)
        }
    }
    
}

struct MPLabelGraphic: Codable {
    var backgroundImage: String
    var content: [Int]
    var stretchX: [[Int]]
    var stretchY: [[Int]]
}
