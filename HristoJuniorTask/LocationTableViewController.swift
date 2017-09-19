//
//  LocationTableViewController.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreData
import CoreLocation
import UIKit

typealias LocationBlock = (PersistentLocation?)->()

class LocationTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageTableViewCellDelegate {
    
    private enum Cells: Int {
        case id
        case address
        case city
        case country
        case latitude
        case longitude
        case image
        case delete
        
        var identifier: String {
            switch self {
            case .latitude, .longitude:
                return String(describing: TextFieldTableViewCell.self)
            case .image:
                return String(describing: ImageTableViewCell.self)
            default:
                return String(describing: UITableViewCell.self)
            }
        }
        
        var title: String? {
            switch self {
            case .id:
                return "ID"
            case .address:
                return "Address"
            case .city:
                return "City"
            case .country:
                return "Country"
            case .latitude:
                return "Latitude"
            case .longitude:
                return "Longitude"
            case .image:
                return "Delete"
            case .delete:
                return "Delete"
            }
        }
        
        func text(from location: PersistentLocation?) -> String? {
            switch self {
            case .id:
                return location?.id
            case .address:
                return location?.address
            case .city:
                return location?.city
            case .country:
                return location?.country
            case .latitude:
                return location?.coordinate?.latitude.rounded(toPlaces: 4).description
            case .longitude:
                return location?.coordinate?.longitude.rounded(toPlaces: 4).description
            default:
                return nil
            }
        }
    }
    
    // MARK: - Properties
    private var location: PersistentLocation?
    private var locationWasChanged = false
    private var updatedLocationBlock: LocationBlock!
    private var imagesWithIDs: [(objectID: NSManagedObjectID, image: UIImage)]?
    private var tableSource: [[Cells]] = [[.id, .address, .city, .country, .latitude, .longitude], [.delete]]
    private lazy var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Life Cycle
    init(location: PersistentLocation, ifUpdated locationBlock: @escaping LocationBlock) {
        super.init(style: .grouped)
        self.location = location
        updatedLocationBlock = locationBlock
        showImages(from: location)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods
    private func firstIndex(of cell: Cells) -> IndexPath? {
        for section in 0..<tableSource.count {
            for row in 0..<tableSource[section].count {
                if tableSource[section][row] == cell {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    private func showImages(from location: PersistentLocation) {
        guard location.images != nil && location.images!.count > 0 else {
            return
        }
        guard let fetchedImagesWithObjectIDs = location.getImagesWithObjectIDs() else {
            return
        }
        imagesWithIDs = fetchedImagesWithObjectIDs
        let imagesSection = Array(repeating: Cells.image, count: imagesWithIDs!.count)
        tableSource.insert(imagesSection, at: 1)
    }
    
    private func initialSetup() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissController))
        navigationItem.leftBarButtonItem = backButton
        let rightButton = UIBarButtonItem(title: "Add Image", style: .plain, target: self, action: #selector(openCamera))
        navigationItem.rightBarButtonItem = rightButton
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cells.address.identifier)
        tableView.register(UINib(nibName: String(describing: ImageTableViewCell.self), bundle: nil), forCellReuseIdentifier: Cells.image.identifier)
        tableView.register(UINib(nibName: String(describing: TextFieldTableViewCell.self), bundle: nil), forCellReuseIdentifier: Cells.latitude.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    @objc private func dismissController() {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: { 
            if self.locationWasChanged {
                self.updatedLocationBlock(self.location)
            }
        })
    }
    
    @objc private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellFromSource = tableSource[indexPath.section][indexPath.row]
        switch cellFromSource {
        case .latitude, .longitude:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellFromSource.identifier, for: indexPath) as! TextFieldTableViewCell
            cell.leftTextLabel.text = cellFromSource.title
            cell.leftTextLabel.textColor = .gray
            cell.textField.text = cellFromSource.text(from: location)
            cell.textField.delegate = self
            cell.textField.tag = cellFromSource.rawValue
            cell.textField.keyboardType = .numbersAndPunctuation
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellFromSource.identifier, for: indexPath) as! ImageTableViewCell
            cell.set(imagesWithIDs![indexPath.row].image)
            cell.button.setTitle(cellFromSource.title, for: .normal)
            cell.delegate = self
            return cell
        case .delete:
            let cell =  tableView.dequeueReusableCell(withIdentifier: cellFromSource.identifier, for: indexPath)
            cell.textLabel?.text = cellFromSource.title
            cell.textLabel?.textColor = .red
            cell.detailTextLabel?.text = nil
            return cell
        default:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellFromSource.identifier)
            cell.selectionStyle = .none
            cell.textLabel?.text = cellFromSource.title
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.text = cellFromSource.text(from: location)
            cell.detailTextLabel?.textColor = .gray
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableSource[indexPath.section][indexPath.row] == .delete && location != nil {
            context.delete(location!)
            location = nil
            locationWasChanged = true
            dismissController()
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let newValue = Double(text) else {
            switch textField.tag {
            case Cells.latitude.rawValue:
                textField.text = location?.coordinate?.latitude.description
            case Cells.longitude.rawValue:
                textField.text = location?.coordinate?.longitude.description
            default:
                break
            }
            return
        }
        switch textField.tag {
        case Cells.latitude.rawValue:
            location?.coordinate?.latitude = newValue
            locationWasChanged = true
        case Cells.longitude.rawValue:
            location?.coordinate?.longitude = newValue
            locationWasChanged = true
        default:
            break
        }
    }
    
    // MARK: - ImageTableViewCellDelegate
    func tapped(_ button: UIButton, in cell: ImageTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), imagesWithIDs != nil else {
            return
        }
        let imageWithID = imagesWithIDs!.remove(at: indexPath.row)
        context.delete(context.object(with: imageWithID.objectID))
        if tableSource[1].count > 1 {
            tableSource[1].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            tableSource.remove(at: 1)
            tableView.deleteSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            let image = info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as! UIImage
            if self.imagesWithIDs == nil { self.imagesWithIDs = [] }
            guard let persistentImage = self.location?.add(image, in: self.context) else {
                return
            }
            self.imagesWithIDs?.insert((objectID: persistentImage.objectID, image: image), at: 0)
            if self.tableSource.count == 3 {
                self.tableSource[1].append(.image)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .bottom)
            } else {
                self.tableSource.insert([.image], at: 1)
                self.tableView.insertSections(IndexSet(integer: 1), with: .bottom)
            }
        }
    }
    
}
