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
    
    @IBAction private func crossButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func feedBacksBtnPressed(_ sender: Any) {
        let email = "foo@bar.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction private func signOutBtnPressed(_ sender: UIButton) {
        
        let keyResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Ding: \(keyResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
    }
    
    @IBAction func fbLikeBtnPressed(_ sender: Any) {
        UIApplication.tryURL(urls: [
            "fb://profile/FYP-1039768376168103/", // App
            "http://www.facebook.com/FYP-1039768376168103/" // Website if app fails
            ])
        
    }
    
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                //application.openURL(URL(string: url)!)
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}
