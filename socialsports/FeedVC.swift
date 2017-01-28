//
//  FeedVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 6/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_GAMES.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                self.games = []
                
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let gameDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let game = Game(gameKey: key, postData: gameDict)
                        self.games.append(game)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = games[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
            cell.configureCell(game: game)
            return cell
        } else {
            return GameCell()
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToProfile", sender: nil)
    }




}
