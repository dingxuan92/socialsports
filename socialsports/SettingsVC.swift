//
//  SettingsVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 28/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SettingsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func crossButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnPressed(_ sender: UIButton) {
        
        let keyResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Ding: \(keyResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
    }

    

}
