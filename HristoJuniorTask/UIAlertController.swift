//
//  Extensions.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 16/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func showWithOkButton(andMessage message: String?) {
        showWithOkButton(title: nil, message: message, in: nil, completionBlock: nil)
    }
    
    static func showWithOkButton(title: String?, message: String?, in controller: UIViewController? = nil, completionBlock: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
            completionBlock?()
        }))
        let presentingController = controller ?? UIApplication.shared.keyWindow?.rootViewController
        presentingController?.present(alertController, animated: true, completion: nil)
    }
}

