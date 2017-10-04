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
import CoreLocation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tableView: UITableView!

    
    var games = [Game]()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    private var currentTime = Date()
    private lazy var FeedRef: FIRDatabaseReference = DataService.ds.REF_GAMES
    private var FeedRefHandle: FIRDatabaseHandle?
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let user = FIRAuth.auth()?.currentUser {
            if let photoURL = user.photoURL {
                let data = NSData(contentsOf: photoURL)
                profileImg.image = UIImage(data: data! as Data)
            }
            if let name = user.displayName {
                userName.text = name
            }
        }
        observeFeed()
    }
    
    deinit {
        if let refHandle = FeedRefHandle {
            FeedRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
        print(Location.sharedInstance.latitude, Location.sharedInstance.longitude)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: GameCell = tableView.cellForRow(at: indexPath) as! GameCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none //to remove the selected gray background
        
        let selectedGame = games[indexPath.row]
        
        performSegue(withIdentifier: "FeedToGameDetail", sender: selectedGame)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FeedToGameDetail" {
            if let detailVC = segue.destination as? GameDetailVC {
                if let game = sender as? Game {
                    detailVC.selectedGame = game
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = games[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
            if let img = FeedVC.imageCache.object(forKey: game.imageUrl as NSString) {
                cell.configureCell(game: game, img: img)
                
                return cell
            }
            cell.configureCell(game: game)
            return cell
        } else {
            return GameCell()
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToProfile", sender: nil)
    }

    @IBAction func addGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToAddGameVC", sender: nil)
    }
    @IBAction func mapBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToMap", sender: nil)
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    private func observeFeed() {
        
        let timeStampFormat = DateFormatter()
        timeStampFormat.dateFormat = "YYYYMMddHHmm"
        let currentTimeStamp = timeStampFormat.string(from: currentTime)
        
        FeedRefHandle = FeedRef.queryOrdered(byChild: "timeStamp").queryStarting(atValue: currentTimeStamp).observe(.value, with: { (snapshot) in
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
    



}
