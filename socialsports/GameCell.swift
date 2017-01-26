//
//  GameCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 24/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blurView.layer.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha:0.21).cgColor
        
        //findATeamLabel.sendSubviewToBack(blurView)
    }
    

    

}
