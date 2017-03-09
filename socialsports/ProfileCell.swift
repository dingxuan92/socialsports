//
//  ProfileCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 29/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profBlurView: UIView!
    @IBOutlet weak var profTitleLbl: UILabel!
    @IBOutlet weak var profGameImg: UIImageView!
    @IBOutlet weak var profTime: UILabel!
    @IBOutlet weak var profLocation: UILabel!
    @IBOutlet weak var profView: UIView!
    
    private var game: Game!
    private var gameRef: FIRDatabaseReference!
    private var imgUrl: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profView.layer.backgroundColor = UIColor(white: 1, alpha: 0.6).cgColor

    }
    
    func configureCell(game: Game, img: UIImage? = nil) {
        self.game = game
        
        gameRef = DataService.ds.REF_GAMES
        
        gameRef.child(game.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let date = value?["date"] as? String {
                if let time = value?["time"] as? String {
                    self.profTime.text = "\(date), \(time)"
                }
            }
            
            if let title = value?["title"] as? String {
                self.profTitleLbl.text = title
            }
            
            if let imgURL = value?["imageUrl"] as? String {
                self.imgUrl = imgURL
                
                
                let ref = FIRStorage.storage().reference(forURL: self.imgUrl)
                ref.data(withMaxSize: 4 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("DING: Unable to download image from Firebase Storage")
                    } else {
                        print("DING: Image downloaded from firebase storage")
                        if let imgData = data { //save the image downloaded from storage into cache
                            if let img = UIImage(data: imgData) {
                                self.profGameImg.image = img
                            }
                        }
                    }
                })
                
            }
        })
        
        gameRef.child(game.gameKey).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let location = value?["name"] as? String {
                self.profLocation.text = location
            }
        })
    }
}
