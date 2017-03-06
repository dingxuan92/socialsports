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
        profView.layer.backgroundColor = UIColor(white: 1, alpha: 0.6).cgColor

    }

    
}
