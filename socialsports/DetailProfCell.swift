//
//  DetailProfCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 4/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase

class DetailProfCell: UICollectionViewCell {
    
    @IBOutlet weak var profImg: CircleView!
    @IBOutlet weak var nameLbl: UILabel!
    
    private var profile: Profile!
    private var userRef: FIRDatabaseReference!
    
    func configureCell(profile: Profile) {
        
        self.profile = profile
        userRef = DataService.ds.REF_USERS.child(self.profile.userKey).child("profile")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let username = value?["displayName"] as? String {
                self.nameLbl.text = username
            }
            if let img = value?["profileURL"] as? String {
                if let imgURL = NSURL(string: img) {
                    let data = NSData(contentsOf: imgURL as URL)
                    self.profImg.image = UIImage(data: data! as Data)
                }
            }
        })
    }
}
