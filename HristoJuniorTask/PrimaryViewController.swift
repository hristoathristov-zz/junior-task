//
//  PrimaryViewController.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreData
import GoogleMaps

class PrimaryViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - Properties
    @IBOutlet private var mapView: GMSMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    private var markers: [GMSMarker]? {
        didSet {
            guard let markers = markers, markers.count > 0 else {
                return
            }
            markers.show(on: self.mapView)
        }
    }
    private lazy var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showPreviousMarkers()
        showCurrentLocation()
    }
    
    // MARK: - Methods
    private func showPreviousMarkers() {
        PersistentLocation.load(in: self.context, all: { (locations) in
            locations.create(inBlock: { (markers) in
                self.markers = markers
            })
        })
    }
    
    private func showCurrentLocation() {
        CustomLocationManager.shared.getCurrent { (location) in
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
            self.mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        }
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D, with persistentLocation: PersistentLocation?, andZoom zoom: Bool?) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: .gray)
        marker.title = "Loading..."
        marker.isDraggable = true
        marker.map = mapView
        self.mapView.selectedMarker = marker
        coordinate.fetch { (geocoding) in
            let address = geocoding.address
            marker.title = address
            marker.snippet = "TAP for details OR DRAG to relocate"
            marker.icon = GMSMarker.markerImage(with: .blue)
            guard let location = persistentLocation else {
                marker.userData = PersistentLocation(geocoding: geocoding, coordinate: coordinate, insertInto: self.context)
                if zoom == true {
                    self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
                }
                return
            }
            location.coordinate?.latitude = marker.position.latitude
            location.coordinate?.longitude = marker.position.longitude
            location.map(geocoding, inside: self.context)
            marker.userData = location
            if zoom == true {
                self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
            }
        }
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D, andZoom zoom: Bool?) {
        addMarker(at: coordinate, with: nil, andZoom: zoom)
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        addMarker(at: coordinate, andZoom: false)
    }
    
    private func updatePosition(of marker: GMSMarker) {
        guard let location = marker.userData as? PersistentLocation else {
            return
        }
        marker.icon = GMSMarker.markerImage(with: .gray)
        marker.title = "Loading..."
        marker.snippet = nil
        mapView.selectedMarker = marker
        marker.position.fetch(successBlock: { (geocoding) in
            marker.icon = GMSMarker.markerImage(with: .blue)
            let address = geocoding.address
            marker.title = address
            marker.snippet = "TAP for details OR DRAG to relocate"
            location.map(geocoding, inside: self.context)
            location.coordinate?.latitude = marker.position.latitude
            location.coordinate?.longitude = marker.position.longitude
            self.mapView.selectedMarker = marker
        }, failureBlock: { (error) in
            UIAlertController.showWithOkButton(andMessage: error.localizedDescription)
            guard let coordinate = location.coordinate else {
                marker.map = nil
                return
            }
            let oldCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.addMarker(at: oldCoordinate, with: marker.userData as? PersistentLocation, andZoom: true)
            marker.map = nil
        })
    }
    
    private func showDetailsController(for marker: GMSMarker) {
        guard let markersLocation = marker.userData as? PersistentLocation else {
            return
        }
        mapView.selectedMarker = nil
        let controller = LocationTableViewController(location: markersLocation, ifUpdated: { (location) in
            guard let position = location?.coordinate else {
                marker.map = nil
                return
            }
            marker.map = nil
            let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            self.addMarker(at: coordinate, with: location, andZoom: true)
        })
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }
    
    //MARK: - GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addMarker(at: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        showDetailsController(for: marker)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        showDetailsController(for: marker)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        updatePosition(of: marker)
    }
}
