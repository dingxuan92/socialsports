//
//  GameDetailVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 2/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase

class GameDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedGame: Game!
    
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameBlurView: UIView!
    @IBOutlet weak var titleBlurView: UIView!
    @IBOutlet weak var gameDate: UILabel!
    @IBOutlet weak var gameLocation: UILabel!
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var attendanceLbl: UILabel!
    
    var profiles = [Profile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        
        updateMainUI()
        
        DataService.ds.REF_GAMES.child(selectedGame.gameKey).child("attending").observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                self.profiles = []
                
                for snap in snapshot {
                    let key = snap.key
                    let userProfile = Profile(key: key)
                    self.profiles.append(userProfile)
                }
                self.attendanceLbl.text = "\(self.profiles.count) going"
            }
            self.collection.reloadData()
        })
        
        
    }
    
    override internal var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profile = profiles[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailProfCell", for: indexPath) as? DetailProfCell {
            
            cell.configureCell(profile: profile)
            return cell
    
        } else {
            return DetailProfCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func updateMainUI() {
        
        gameTitle.text = selectedGame.title
        gameDate.text = "\(selectedGame.date), \(selectedGame.time)"
        gameLocation.text = selectedGame.location
        
        let ref = FIRStorage.storage().reference(forURL: selectedGame.imageUrl)
        ref.data(withMaxSize: 4 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("DING: Unable to download image from Firebase Storage")
            } else {
                print("DING: Image downloaded from firebase storage")
                if let imgData = data { //save the image downloaded from storage into cache
                    if let img = UIImage(data: imgData) {
                        self.gameImg.image = img
                    }
                }
            }
        })
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "DetailToFeed", sender: nil)
    }
    
    @IBAction func addGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "DetailToAdd", sender: nil)
    }
    
    @IBAction func mapBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "DetailToMap", sender: nil)
    }

}
