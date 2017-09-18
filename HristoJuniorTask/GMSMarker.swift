//
//  GMSMarker.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import GoogleMaps

extension Array where Element: GMSMarker {
    
    func show(on map: GMSMapView) {
        for marker in self {
            marker.map = map
        }
    }
}
