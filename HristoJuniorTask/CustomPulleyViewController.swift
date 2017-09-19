//
//  CustomPulleyViewController.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 19/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import GoogleMaps
import Pulley

class CustomPulleyViewController: PulleyViewController {
    
    // MARK: - Properties
    private var contentViewController: MapViewController!
    private var drawerViewController: DrawerTableViewController!
    
    // MARK: - Life Cycle
    init() {
        contentViewController = MapViewController()
        drawerViewController = DrawerTableViewController()
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
        delegate = contentViewController
        contentViewController.delegates.append(drawerViewController)
        drawerViewController.delegate = contentViewController
        drawerCornerRadius = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }
}
