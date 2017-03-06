//
//  CoolTransparentView.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 3/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class CoolTransparentView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha:0.26).cgColor
    }

}
