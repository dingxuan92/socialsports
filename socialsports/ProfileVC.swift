//
//  ProfileVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 23/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import FBSDKCoreKit
import SwiftDate

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileAge: UILabel!
    @IBOutlet weak var profilePlayed: UILabel!
    @IBOutlet weak var profileGender: UIImageView!
    
    private var profileRef: FIRDatabaseReference!
    private var profilePicRef: FIRStorageReference!
    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMainUI()
        observeGames()
    }
    
    private func observeGames() {
        
        DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                self.games = []
                
                for snap in snapshot {
                        let key = snap.key
                        let game = Game(gameKey: key)
                        self.games.insert(game, at: 0)
                }
            }
            
            self.profileTableView.reloadData()
        })
    }
    
    override internal var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction private func settingsBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }

    @IBAction private func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let game = games[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
            cell.configureCell(game: game)
            return cell
        } else {
            return ProfileCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: ProfileCell = tableView.cellForRow(at: indexPath) as! ProfileCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none //to remove the selected gray background
        
        let selectedGame = games[indexPath.row]
        
        performSegue(withIdentifier: "ProfileToGame", sender: selectedGame)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToGame" {
            if let detailVC = segue.destination as? GameDetailVC {
                if let game = sender as? Game {
                    detailVC.selectedGame = game
                }
            }
        }
    }
    
    private func returnFbUserData() {
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, locale"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dictionary = result as? NSDictionary
                    if let fullName = dictionary?.object(forKey: "name") {
                        self.profileName.text = fullName as? String
                    }
                    if let gender = dictionary?.object(forKey: "gender") {
                        if gender as? String == "female" {
                            self.profileGender.image = UIImage(named: "female")
                        }
                    }
                }
            })
            
            FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300, "width":300, "redirect": false]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as? NSDictionary
                    let data = dict?.object(forKey: "data")
                    
                    let urlPic = ((data as AnyObject).object(forKey:"url"))! as! String
                    
                    if let imageData = NSData(contentsOf: NSURL(string:urlPic)! as URL) {
                        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
                        self.profilePicRef = DataService.ds.REF_PROF_PICS.child(uid!+"/profile_pic.jpg")
                        var imageLoaded = false
                        
                        self.profilePicRef.data(withMaxSize: (1 * 1024 * 1024), completion: { (data, error) in
                            if error != nil {
                                print("DING: unable to download image")
                            } else {
                                if data != nil {
                                    print("DING: downloaded image")
                                    self.profileImage.image = UIImage(data: data!)
                                    imageLoaded = true
                                }
                            }
                        })
                        
                        
                        if imageLoaded == false {
                            _ = self.profilePicRef.put(imageData as Data, metadata:nil){
                                metadata,error in
                                
                                if(error == nil) {
                                    _ = metadata!.downloadURL
                                }
                                else
                                {
                                    print("Error in downloading image")
                                }
                            }
                            
                            self.profileImage.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            })
        }
    }
    
    private func updateMainUI() {
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        profileRef = DataService.ds.REF_USERS_CURRENT
        
        profileRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            if let provider = snapshot.childSnapshot(forPath: "profile/provider").value as! String! {
                if provider == "facebook.com" {
                    print("yes it is facebook")
                    self.returnFbUserData()
                    let numberPlayed = snapshot.childSnapshot(forPath: "gamesAccepted").childrenCount
                    self.profilePlayed.text = "\(numberPlayed)"
                } else {
                    if let user = FIRAuth.auth()?.currentUser {
                        if let photoURL = user.photoURL {
                            let data = NSData(contentsOf: photoURL)
                            self.profileImage.image = UIImage(data: data as! Data)
                        }
                        if let name = user.displayName {
                            self.profileName.text = name
                        }
                    }
                    let numberPlayed = snapshot.childSnapshot(forPath: "gamesAccepted").childrenCount
                    self.profilePlayed.text = "\(numberPlayed)"
                }
            }
        })
    }
    
    @IBAction func addGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "profileToAddGame", sender: nil)
        
    }

    @IBAction func feedBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "ProfileToFeed", sender: nil)
        
        
    }
    
    
}

