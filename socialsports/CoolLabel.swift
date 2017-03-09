//
//  CoolLabel.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 8/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class CoolLabel: UILabel {

    override func awakeFromNib() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10.0
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 5, left: 28, bottom: 5, right: 10)))
    }

}
