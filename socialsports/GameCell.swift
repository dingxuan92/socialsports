//
//  GameCell.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 24/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate
import SwiftKeychainWrapper
import CoreLocation

class GameCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var numPlayersLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    private var game: Game!
    
    
    private var likesRef: FIRDatabaseReference!
    private var userRef: FIRDatabaseReference!
    private var gameRef: FIRDatabaseReference!
    
    let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        blurView.bringSubview(toFront: titleLbl)
        
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 1            //hard code the gesture recognizer because table view cell, storyboard linking cannot differentiate which cell
        likeImg.addGestureRecognizer(likeTap)
        likeImg.isUserInteractionEnabled = true
        
        let acceptTap = UITapGestureRecognizer(target: self, action: #selector(acceptTapped))
        acceptTap.numberOfTapsRequired = 1
        acceptButton.addGestureRecognizer(acceptTap)
        acceptButton.isUserInteractionEnabled = true
        
        
    }
    
    //Update UI
    func configureCell(game: Game, img: UIImage? = nil) {
        self.game = game
        
        likesRef = DataService.ds.REF_USERS_CURRENT.child("likes").child(game.gameKey)
        userRef = DataService.ds.REF_USERS.child(game.creator).child("profile")
        gameRef = DataService.ds.REF_GAMES
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let username = value?["displayName"] as? String {
            self.usernameLbl.text = username
            }
            if let img = value?["profileURL"] as? String {
                if let imgURL = NSURL(string: img) {
                    let data = NSData(contentsOf: imgURL as URL)
                    self.profileImg.image = UIImage(data: data as! Data)
                }
            }
        })
        
        
        
        gameRef.child(game.gameKey).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let lat = value?["latitude"] as? Double {
                if let long = value?["longitude"] as? Double {
                    let gameCoordinates = CLLocation(latitude: lat, longitude: long)
                    let userCoordinates = CLLocation(latitude: Location.sharedInstance.latitude, longitude: Location.sharedInstance.longitude)
                    let distanceInMeters = userCoordinates.distance(from: gameCoordinates) / 1000
                    let distanceInOneDecimal = round(distanceInMeters * 10) / 10
                    self.distanceLbl.text = "\(distanceInOneDecimal) km"
                }
            }
        })
        
        gameRef.child(game.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let date = value?["date"] as? String {
                if let time = value?["time"] as? String {
                    self.timeLbl.text = "\(date), \(time)"
                }
            }
            let count = snapshot.childSnapshot(forPath: "attending").childrenCount
            let max = snapshot.childSnapshot(forPath: "maxppl").value
            self.numPlayersLbl.text = "\(count) / \(max!)"
            
        })
    
        self.titleLbl.text = game.title
        self.likesLbl.text = "\(game.likes)"
        self.numPlayersLbl.text = "\(game.attendance) / \(game.maxppl)"
        
        if img != nil { //if image exist in cache
            self.gameImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: game.imageUrl)
            ref.data(withMaxSize: 4 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("DING: Unable to download image from Firebase Storage")
                } else {
                    print("DING: Image downloaded from firebase storage")
                    if let imgData = data { //save the image downloaded from storage into cache
                        if let img = UIImage(data: imgData) {
                            self.gameImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: game.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        //Determine if the event is liked by the current user
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "unfilledStar")
            } else {
                self.likeImg.image = UIImage(named: "filledStar")
            }
        })
        
        //Determine if the event is accepted by the current user
        DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(game.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.acceptButton.setImage(UIImage(named: "acceptButton"), for: .normal)
            } else {
                self.acceptButton.setImage(UIImage(named: "acceptedButton"), for: .normal)
            }
        })
        
        
    }
    
    @objc private func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filledStar")
                self.game.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "unfilledStar")
                self.game.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
        
    }
    
    @objc private func acceptTapped(sender: UITapGestureRecognizer) {
        DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(game.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.acceptButton.setImage(UIImage(named: "acceptedButton"), for: .normal)
                DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(self.game.gameKey).setValue(true)
                DataService.ds.REF_GAMES.child(self.game.gameKey).child("attending").child(self.uid!).setValue(true)
            } else {
                self.acceptButton.setImage(UIImage(named: "acceptButton"), for: .normal)
                DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(self.game.gameKey).removeValue()
                DataService.ds.REF_GAMES.child(self.game.gameKey).child("attending").child(self.uid!).removeValue()
            }
        })
    }
}




