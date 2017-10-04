//
//  FancyLabel.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 2/2/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class FancyLabel: UILabel {

    override func awakeFromNib() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10.0
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)))
    }

}
