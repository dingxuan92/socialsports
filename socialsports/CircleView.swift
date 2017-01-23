//
//  CircleView.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 23/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
