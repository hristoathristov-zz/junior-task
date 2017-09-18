//
//  ImageTableViewCell.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet private var aspectFitImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(rgb: 0x007ffa)
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            
        }
    }
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                aspectFitImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                aspectFitImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func set(_ image : UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        aspectConstraint = NSLayoutConstraint(item: aspectFitImageView, attribute: .width, relatedBy: .equal, toItem: aspectFitImageView, attribute: .height, multiplier: aspect, constant: 0.0)
        
        aspectFitImageView.image = image
    }

}
