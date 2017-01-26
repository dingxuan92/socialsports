//
//  DataService.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 25/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService() // static is global -> reference to itself (easy accessibility)
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_GAMES = DB_BASE.child("game")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference { //so that you can only read but not write?
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_GAMES
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USERS_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,String>) {
        REF_USERS.child(uid).updateChildValues(userData)
        //if uid dosn't exist in database, it will create a new one for the uid
    }
    
    
    
}
