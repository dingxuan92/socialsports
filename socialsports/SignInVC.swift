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
import GoogleSignIn

class SignInVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    @IBAction private func googleButtonPressed(_ sender: Any) {
        actInd.isHidden = false
        actInd.startAnimating()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction private func fbButtonPressed(_ sender: Any) {
        actInd.isHidden = false
        actInd.startAnimating()
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                
                print("Ding: Unable to authenticate with Facebook - \(String(describing: error))")
                
            } else if result?.isCancelled == true {
                self.actInd.stopAnimating()
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
                print("Ding: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("Ding: Successfully authenticated with Firebase")
                if let user = user {
                    var userData = ["provider": credential.provider]
                    
                    if let name = user.displayName {
                        userData["displayName"] = name
                    }
                    if let profilePhotoURL = user.photoURL {
                        userData["profileURL"] = profilePhotoURL.absoluteString
                    }
                    if let email = user.email {
                        userData["email"] = email
                    }
                    self.actInd.stopAnimating()
                    self.completeSignIn(id: user.uid, userData: userData as Dictionary<String, AnyObject>)
                }
            }
        })
        
    }
    
    internal func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else {
            print("Ding: Unable to authenticate with Google")
            return
        }
        print("Ding: Successfully authenticated with Google.")
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        self.firebaseAuth(credential)
    }
    
    internal func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    
    private func completeSignIn(id: String, userData: Dictionary<String, AnyObject>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keyChainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Ding: Data saved to keychain \(keyChainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}



