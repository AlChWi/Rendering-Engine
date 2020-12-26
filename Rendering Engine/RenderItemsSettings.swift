//
//  RenderItemsSettings.swift
//  Rendering Engine
//
//  Created by AlChWi on 12/25/20.
//

import AppKit

enum ModelSetting: String {
    case position
    case rotation
    case scale
    case delete
    
    static func casesCount() -> Int {
        return 4
    }
}
//var position: float3 = [0, 0, 0]
//var rotation: float3 = [0, 0, 0]
//var scale: float3 = [1, 1, 1]

enum LightSetting: String {
    case position
    case lightType
    case intensity
    case attenuation
    case color
    case delete
    
    static func casesCount() -> Int {
        return 6
    }
}
//light.type = Pointlight
//light.intensity = 1
//light.attenuation = [1, 1, 1]
//light.position = [0, 0.5, 0.5]
//light.color = [1, 0, 0]
