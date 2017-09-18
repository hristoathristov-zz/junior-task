//
//  GeocodingRequest.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Alamofire

class GeocodingRequest: BaseRequest<Geocoding> {
    
    init(latitude: Double, longitude: Double) {
        super.init(url: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(GOOGLE_MAPS_API_KEY)")
    }
//    
//    override func execute(successBlock: @escaping (Geocoding) -> (), failureBlock: ((Error) -> ())?) {
//        super.execute(successBlock: { (geocoding) in
//            guard let error = geocoding.error else {
//                successBlock(geocoding)
//                return
//            }
//            failureBlock?(NSError(domain: error, code: 0, userInfo: nil))
//        }, failureBlock: { (error) in
//            failureBlock?(error)
//        })
//    }
}
