//
//  Double.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 18/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Foundation

extension Double {

    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
