//
//  DrawerTableViewController.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 19/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import GoogleMaps

@objc protocol DrawerTableViewControllerDelegate {
    func inDrawerTableViewController(wasSelected marker: GMSMarker)
}

class DrawerTableViewController: UITableViewController, MapViewControllerDelegate {
    
    // MARK: - Properties
    private var markers: [GMSMarker]?
    private lazy var cellId = String(describing: UITableViewCell.self)
    var delegate: DrawerTableViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (markers?.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = indexPath.row == 0 ? "Tap on map to add a marker" : markers?[indexPath.row - 1].title
        cell.imageView?.image = #imageLiteral(resourceName: "pin")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0, let marker = markers?[indexPath.row - 1] {
            delegate?.inDrawerTableViewController(wasSelected: marker)
        }
    }
    
    // MARK: - MapViewControllerDelegate
    func mapViewController(set markers: [GMSMarker]?) {
        self.markers = markers
        self.tableView.reloadData()
    }
    
    func mapViewController(added marker: GMSMarker) {
        if markers != nil {
            self.markers?.insert(marker, at: 0)
        } else {
            markers = [marker]
        }
        self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
    }
    
    func mapViewController(updated marker: GMSMarker) {
        if let row = markers?.index(of: marker) {
            let index = IndexPath(row: row + 1, section: 0)
            if let _ = tableView.indexPathsForVisibleRows?.contains(index), let cell = tableView.cellForRow(at: index) {
                cell.textLabel?.text = marker.title
            }
        }
    }

    func mapViewController(deleted marker: GMSMarker, from total: Int) {
        if let index = self.markers?.index(of: marker) {
            self.markers?.remove(at: index)
            let indexPath = IndexPath(row: index + 1, section: 0)
            if let _ = tableView.indexPathsForVisibleRows?.contains(indexPath) {
                tableView.deleteRows(at: [indexPath], with: .top)
            }
            
        }
    }
}
