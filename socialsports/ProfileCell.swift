//
//  ProfileCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 29/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profBlurView: UIView!
    @IBOutlet weak var profTitleLbl: UILabel!
    @IBOutlet weak var profGameImg: UIImageView!
    @IBOutlet weak var profTime: UILabel!
    @IBOutlet weak var profLocation: UILabel!
    @IBOutlet weak var profView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profBlurView.layer.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha:0.26).cgColor
        profView.layer.backgroundColor = UIColor(white: 1, alpha: 0.6).cgColor
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = profBlurView.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        profBlurView.addSubview(blurEffectView)
//        profBlurView.bringSubview(toFront: profTitleLbl)
    }

    
}
