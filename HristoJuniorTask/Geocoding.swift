//
//  Geocoding.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import ObjectMapper

class Geocoding: Mappable {
    
    var results: [GeocodingResult]?
    var status: String?
    var error: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        results <- map["results"]
        status <- map["status"]
        error <- map["error_message"]
    }
}

extension Geocoding {
    
    fileprivate var addressResult: GeocodingResult? {
        return results?.filter({ $0.types?.contains("street_address") ?? false }).first
    }
    
    var id: String? {
        return addressResult?.placeId ?? nil
    }
    
    var address: String? {
        guard let result = addressResult,
            let street = result.component(withType: "route")?.longName,
            let number = result.component(withType: "street_number")?.longName else {
            return nil
        }
        return "\(street) \(number)"
    }
    
    var city: String? {
        return addressResult?.component(withType: "locality")?.longName ?? nil
    }
    
    var country: String? {
        return addressResult?.component(withType: "country")?.longName ?? nil
    }
}

class GeocodingResult: Mappable {
    
    var addressComponents: [GeocodingAddressComponent]?
    var formattedAddress: String?
    var geometry: GeocodingGeometry?
    var placeId: String?
    var types: [String]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        addressComponents <- map["address_components"]
        formattedAddress <- map["formatted_address"]
        geometry <- map["geometry"]
        placeId <- map["place_id"]
        types <- map["types"]
    }
}

extension GeocodingResult {
    
    func component(withType types: String...) -> GeocodingAddressComponent? {
        return addressComponents?.filter({ (component) -> Bool in
            guard component.types != nil && component.types!.count > 0 else {
                return false
            }
            for type in types {
                if !component.types!.contains(type) { return false }
            }
            return true
        }).first ?? nil
    }
}

class GeocodingAddressComponent: Mappable {
    
    var longName: String?
    var shortName: String?
    var types: [String]?
    
    required init(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        longName <- map["long_name"]
        shortName <- map["short_name"]
        types <- map["types"]
    }
}

class GeocodingGeometry: Mappable {
    
    var bounds: GeocodingDiagonal?
    var location: GeocodingCoordinate?
    var locationType: String?
    var viewport: GeocodingDiagonal?
    
    required init(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        bounds <- map["bounds"]
        location <- map["location"]
        locationType <- map["location_type"]
        viewport <- map["viewport"]
    }
}

class GeocodingDiagonal: Mappable {
    
    var northeast: GeocodingCoordinate?
    var southwest: GeocodingCoordinate?
    
    required init(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        northeast <- map["northeast"]
        southwest <- map["southwest"]
    }
}

class GeocodingCoordinate: Mappable {
    
    var latitude: Double?
    var longitude: Double?
    
    required init(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        latitude <- map["lat"]
        longitude <- map["lng"]
    }
}
