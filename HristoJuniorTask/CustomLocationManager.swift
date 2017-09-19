//
//  CustomLocationManager.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreLocation
import UIKit

let GOOGLE_MAPS_API_KEY = "AIzaSyDFXX_Wz6Z6QYz5qYuVQvip09SQxl905DI"

typealias FoundLocationBlock = ((CLLocation)->())

class CustomLocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    internal static let shared = CustomLocationManager()
    fileprivate lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    fileprivate var foundLocationBlock: FoundLocationBlock?
    
    // MARK: - Initializers
    /**
     * The initializer is fileprivate so that only the shared instance can be used.
     */
    fileprivate override init() {
        super.init()
    }
    
    // MARK: - Methods
    func getCurrent(foundLocationBlock: @escaping FoundLocationBlock) {
        self.foundLocationBlock = foundLocationBlock
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            fallthrough
        case .denied:
            showAlertForDeniedLocation()
        }
    }
    
    fileprivate func showAlertForDeniedLocation() {
        UIAlertController.showWithOkButton(andMessage: "If You would like to see Your location on the map, please authorize the app in the Settings menu.")
    }
    
    // MARK: - CLLocationManagerDelegate implementation
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            showAlertForDeniedLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first, let returnInBlock = foundLocationBlock else {
            return
        }
        returnInBlock(currentLocation)
        foundLocationBlock = nil
        locationManager.stopUpdatingLocation()
    }
}
