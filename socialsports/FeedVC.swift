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

class FeedVC: UIViewController {
    
    @IBAction func signOutBtnPressed(_ sender: UIButton) {
        
        let keyResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Ding: \(keyResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    




}
