//
//  CLLocationCoordinate2DExtension.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    func fetch(_ successBlock: @escaping (Geocoding)->()) {
        fetch(successBlock: successBlock, failureBlock: nil)
    }
    
    func fetch(successBlock:@escaping (Geocoding)->(), failureBlock: ((Error)->())?) {
        let request = GeocodingRequest(latitude: latitude, longitude: longitude)
//        request.execute(successBlock: successBlock, failureBlock: failureBlock)
        request.execute(successBlock: { (geocoding) in
            guard let error = geocoding.error else {
                successBlock(geocoding)
                return
            }
            failureBlock?(NSError(domain: error, code: 0, userInfo: nil))
        }, failureBlock: { (error) in
            failureBlock?(error)
        })
    }
}
