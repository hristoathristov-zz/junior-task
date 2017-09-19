//
//  PrimViewController.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 19/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreData
import GoogleMaps
import Pulley

@objc protocol MapViewControllerDelegate {
    @objc optional func mapViewController(set markers: [GMSMarker]?)
    @objc optional func mapViewController(added marker: GMSMarker)
    @objc optional func mapViewController(updated marker: GMSMarker)
    @objc optional func mapViewController(deleted marker: GMSMarker, from total: Int)
}

extension Array where Element: MapViewControllerDelegate {
    
    func notifyAbout(setting markers: [GMSMarker]?) {
        for delegate in self { delegate.mapViewController?(set: markers) }
    }
    
    func notifyAbout(adding marker: GMSMarker) {
        for delegate in self { delegate.mapViewController?(added: marker) }
    }
    
    func notifyAbout(updating marker: GMSMarker) {
        for delegate in self { delegate.mapViewController?(updated: marker) }
    }
    
    func notifyAbout(deleting marker: GMSMarker, from total: Int) {
        for delegate in self { delegate.mapViewController?(deleted: marker, from: total) }
    }
}

class MapViewController: UIViewController, GMSMapViewDelegate, PulleyDelegate, DrawerTableViewControllerDelegate {
    
    private var mapView: GMSMapView!
    private var markers: [GMSMarker]?
    lazy var delegates: [MapViewControllerDelegate] = []
    private lazy var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = GMSMapView(frame: CGRect.zero)
        mapView.delegate = self
        view = mapView
        showPreviousMarkers()
        showCurrentLocation()
    }
    
    // MARK: - Methods
    /**
     * Shows markers that have been added previously and saved to CoreData.
     */
    private func showPreviousMarkers() {
        PersistentLocation.load(in: self.context, all: { (locations) in
            if locations.count > 0 {
                locations.create(inBlock: { (markers) in
                    self.markers = markers
                    self.markers?.show(on: self.mapView)
                    self.delegates.notifyAbout(setting: markers)
                })
            }
        })
    }
    
    /**
     * Tries to show the current location on the map. If the user declines the authorization, a message appears.
     */
    private func showCurrentLocation() {
        CustomLocationManager.shared.getCurrent { (location) in
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
            self.mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        }
    }
    
    /**
     * Adds a marker on the map.
     * - parameter coordinate: the coordinate at which the marker is added
     * - parameter persistentLocation: if passed, it is set as the markers' 'userData' property, so that previously added images are not lost
     * - parameter andZoom: if true, the map will zoom into the new marker
     */
    private func addMarker(at coordinate: CLLocationCoordinate2D, with persistentLocation: PersistentLocation?, andZoom zoom: Bool?) {
        let marker = GMSMarker(position: coordinate)
        if markers == nil { markers = [] }
        markers?.append(marker)
        marker.icon = GMSMarker.markerImage(with: .gray)
        marker.title = "Loading..."
        marker.isDraggable = true
        marker.map = mapView
        self.mapView.selectedMarker = marker
        coordinate.fetch { (geocoding) in
            let address = geocoding.address
            marker.title = address
            self.delegates.notifyAbout(adding: marker)
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
    
    /**
     * Fetches the geometry a marker and updated its properties.
     * - parameter marker: the marker whose geometry will be fetched
     */
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
            self.delegates.notifyAbout(updating: marker)
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
    
    /**
     * Shows the details screen of the 'userData' property (of type PersistentLocation)
     * - parameter marker: the marker whose 'userData' (as PersistentLocation) property will be used
     */
    private func showDetailsController(for marker: GMSMarker) {
        guard let markersLocation = marker.userData as? PersistentLocation else {
            return
        }
        mapView.selectedMarker = nil
        let controller = LocationTableViewController(location: markersLocation, ifUpdated: { (location) in
            guard let position = location?.coordinate else {
                if let index = self.markers?.index(of: marker) {
                    self.markers?.remove(at: index)
                    self.delegates.notifyAbout(deleting: marker, from: self.markers!.count)
                }
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
    
    // MARK: - PulleyDelegate
    private var drawerDistanceFromBottom: CGFloat?
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat) {
        if drawerDistanceFromBottom == nil {
            drawerDistanceFromBottom = distance
        }
    }
    
    private var positionWasSet = false
    func drawerPositionDidChange(drawer: PulleyViewController) {
        if !positionWasSet && drawerDistanceFromBottom != nil && (drawer.drawerPosition == .collapsed || drawer.drawerPosition == .closed) {
            view.frame.size.height = UIScreen.main.bounds.size.height - drawerDistanceFromBottom!
        }
    }
    
    // MARK: - DrawerTableViewControllerDelegate
    func inDrawerTableViewController(wasSelected marker: GMSMarker) {
        mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
        mapView.selectedMarker = marker
    }
}
