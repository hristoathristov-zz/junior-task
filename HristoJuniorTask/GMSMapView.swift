//
//  GMSMapView.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 18/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    
    func zoom(level: Int, at position: CLLocationCoordinate2D) {
        camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 17)
    }
}