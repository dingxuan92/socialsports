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

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnPressed(_ sender: UIButton) {
        
        let keyResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Ding: \(keyResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
    }
 

}
