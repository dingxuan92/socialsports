//
//  ChatCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 8/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class ChatCell: UITableViewCell {

    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    private var chat: Chat!
    private var userRef: FIRDatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(chat: Chat) {
        
        self.chat = chat
        messageLbl.text = self.chat.message
        messageLbl.sizeToFit()
        let timeString = self.chat.timeStamp
        
        let date = try! DateInRegion(string: timeString, format: .custom("yyyy-MM-dd HH:mm:ss"), fromRegion: nil)
        
        let (colloquial, _) = try! date.colloquialSinceNow()
        
        let newColloquial = colloquial.replacingOccurrences(of: "minutes", with: "min")
        let newColloquial2 = newColloquial.replacingOccurrences(of: "one", with: "1")
        
        self.timeLbl.text = newColloquial2

        userRef = DataService.ds.REF_USERS.child(self.chat.uid).child("profile")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let username = value?["displayName"] as? String {
                self.displayNameLbl.text = username
            }
            if let img = value?["profileURL"] as? String {
                if let imgURL = NSURL(string: img) {
                    let data = NSData(contentsOf: imgURL as URL)
                    self.profileImg.image = UIImage(data: data! as Data)
                }
            }
        })
    }
}






