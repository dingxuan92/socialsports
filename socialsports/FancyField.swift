//
//  FancyField.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 23/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class FancyField: UITextField {

    
    override func awakeFromNib() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10.0
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }

}
