//
//  ViewController.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 5/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    @IBAction private func fbButtonPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                
                print("Ding: Unable to authenticate with Facebook - \(error)")
                
            } else if result?.isCancelled == true {
                
                print("Ding: User cancelled Facebook Authentication")
                
            } else {
                print("Ding: Successfully authenticated with Facebook")
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    
    
    
    private func firebaseAuth(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                
                print("Ding: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Ding: Successfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
        
    }
    
    private func completeSignIn(id: String) {
        let keyChainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Ding: Data saved to keychain \(keyChainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}



