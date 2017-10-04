//
//  GameDetailVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 2/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate
import SwiftKeychainWrapper

class GameDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var selectedGame: Game!
    
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameBlurView: UIView!
    @IBOutlet weak var titleBlurView: UIView!
    @IBOutlet weak var gameDate: UILabel!
    @IBOutlet weak var gameLocation: UILabel!
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var attendanceLbl: UILabel!
    @IBOutlet weak var chatTextField: FancyField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var editLbl: UIImageView!
    @IBOutlet weak var chatSendImage: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var deleteGameBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIImageView!
    
    
    var profiles = [Profile]()
    var chats = [Chat]()
    var edit = false
    private var profileRefHandle: FIRDatabaseHandle?
    private var chatRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameDetailVC.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        updateMainUI()
        observeProfile()
        observeChat()
        checkIfCreator()
    
    }
    
    deinit {
        if let refHandle = profileRefHandle {
            DataService.ds.REF_GAMES.child(selectedGame.gameKey).child("attending").removeObserver(withHandle: refHandle)
        }
        if let refHandleTwo = chatRefHandle {
            DataService.ds.REF_MESSAGE.child(selectedGame.gameKey).removeObserver(withHandle: refHandleTwo)
        }
    }
    
    override internal var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        
        if let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell {
            
            cell.configureCell(chat: chat)
            return cell
            
        } else {
            return ChatCell()
        }
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
        //click on profile
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
    
    private func updateMainUI() {
        
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
    
    private func observeProfile() {
        profileRefHandle = DataService.ds.REF_GAMES.child(selectedGame.gameKey).child("attending").observe(.value, with: { (snapshot) in
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
    
    private func observeChat() {
        chatRefHandle = DataService.ds.REF_MESSAGE.child(selectedGame.gameKey).observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.chats = []
                
                for snap in snapshot {
                    if let chatDict = snap.value as? Dictionary<String, AnyObject> {
                        let chat = Chat(chatData: chatDict)
                        self.chats.insert(chat, at: 0)
                    }
                }
            }
            self.chatTableView.reloadData()
        })
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    @IBAction func chatBtnTapped(_ sender: Any) {
        
        guard let message = chatTextField.text, message != "" else {
            print("DING: No message input")
            return
        }
        postToFirebase(text: message)
    }
    @IBAction func editBtnPressed(_ sender: Any) {
        if edit == false {
            editLbl.image = UIImage(named: "EditingButton")
            edit = true
            
            chatTableView.isHidden = true
            chatTextField.isHidden = true
            chatSendImage.isHidden = true
            lineView.isHidden = true
            deleteGameBtn.isHidden = false
            
        } else {
            editLbl.image = UIImage(named: "EditButton")
            edit = false
            
            chatTableView.isHidden = false
            chatTextField.isHidden = false
            chatSendImage.isHidden = false
            lineView.isHidden = false
            deleteGameBtn.isHidden = true
        }
    }
    
    @IBAction func DeleteBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        DataService.ds.REF_GAMES.child(selectedGame.gameKey).removeValue()
        
    }
    
    private func postToFirebase(text: String) {
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = formatter.string(from: now)
        
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let post: Dictionary<String, AnyObject> = [
            "uid": uid! as AnyObject,
            "timeStamp": currentTime as AnyObject,
            "message": text as AnyObject
        ]
        let firebasePost = DataService.ds.REF_MESSAGE.child(selectedGame.gameKey).childByAutoId()
        
        firebasePost.setValue(post)
        chatTextField.text = ""
        dismissKeyboard()
        print("Message posted to firebase")
    }
    
    private func checkIfCreator() {
        let gameKey = selectedGame.gameKey
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        
        DataService.ds.REF_GAMES.child(gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let creatorID = snapshot.childSnapshot(forPath: "creator").value as? String {
                if creatorID == uid {
                    self.editLbl.isHidden = false
                } else {
                        self.acceptBtn.isHidden = false
                        DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(self.selectedGame.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let _ = snapshot.value as? NSNull {
                                self.acceptBtn.image = UIImage(named: "acceptBtn")
                            } else {
                                self.acceptBtn.image = UIImage(named: "goingBtn")
                            }
                        })
                }
            }
            
        })
    }
    
    @IBAction func acceptBtnTapped(_ sender: Any) {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        
        DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(selectedGame.gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                
                self.acceptBtn.image = UIImage(named: "goingBtn")
                
                DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(self.selectedGame.gameKey).setValue(true)
                DataService.ds.REF_GAMES.child(self.selectedGame.gameKey).child("attending").child(uid!).setValue(true)
            } else {
                
                self.acceptBtn.image = UIImage(named: "acceptBtn")
                
                DataService.ds.REF_USERS_CURRENT.child("gamesAccepted").child(self.selectedGame.gameKey).removeValue()
                DataService.ds.REF_GAMES.child(self.selectedGame.gameKey).child("attending").child(uid!).removeValue()
            }
            
        })
    }
    
    
}
