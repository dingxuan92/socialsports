//
//  PinkCircleView.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 24/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class PinkCircleView: UIImageView {

    var pink = UIColor(red: 255.0/255.0, green: 163.0/255.0, blue: 142.0/255.0, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        layer.borderWidth = 1
        layer.borderColor = pink.cgColor
        clipsToBounds = true
    }

}
