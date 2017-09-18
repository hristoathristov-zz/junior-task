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
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        addMarker(at: coordinate, andZoom: false)
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D, andZoom zoom: Bool?) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: .gray)
        marker.isDraggable = true
        marker.map = mapView
        coordinate.fetch { (geocoding) in
            let address = geocoding.address
            marker.title = address
            marker.icon = GMSMarker.markerImage(with: .blue)
            self.mapView.selectedMarker = marker
            guard let location = marker.userData as? PersistentLocation else {
                marker.userData = PersistentLocation(id: geocoding.id,
                                                     address: address,
                                                     city: geocoding.city,
                                                     country: geocoding.country,
                                                     coordinate: coordinate,
                                                     insertInto: self.context)
                if zoom == true {
                    self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
                }
                return
            }
            location.map(geocoding)
            if zoom == true {
                self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
            }
        }
    }
    
    private func updatePosition(of marker: GMSMarker) {
        guard let location = marker.userData as? PersistentLocation, let coordinate = location.coordinate else {
            return
        }
        marker.position.fetch(successBlock: { (geocoding) in
            let address = geocoding.address
            marker.title = address
            location.map(geocoding)
            coordinate.latitude = marker.position.latitude
            coordinate.longitude = marker.position.longitude
            self.mapView.selectedMarker = marker
        }, failureBlock: { (error) in
            UIAlertController.showWithOkButton(andMessage: error.localizedDescription)
            marker.position.latitude = coordinate.latitude
            marker.position.longitude = coordinate.longitude
        })
    }
    
    private func showDetailsController(for marker: GMSMarker) {
        guard let location = marker.userData as? PersistentLocation else {
            return
        }
        print(location.coordinate ?? "")
        let controller = LocationTableViewController(location: location, updatedLocationBlock: {
            print(location.coordinate ?? "")
            guard let position = location.coordinate else {
                return
            }
            marker.map = nil
            location.delete(in: self.context)
            let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            self.addMarker(at: coordinate, andZoom: true)
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
