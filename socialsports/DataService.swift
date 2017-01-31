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
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService() // static is global -> reference to itself (easy accessibility)
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_GAMES = DB_BASE.child("game")
    private var _REF_USERS = DB_BASE.child("users")
    
    // Storage references
    
    private var _REF_GAME_IMAGES = STORAGE_BASE.child("games")
    private var _REF_PROF_PICS = STORAGE_BASE.child("profilepic")
    
    //Database
    
    var REF_BASE: FIRDatabaseReference { //so that you can only read but not write?
        return _REF_BASE
    }
    
    var REF_GAMES: FIRDatabaseReference {
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
    
    //Storage
    
    var REF_GAME_IMAGES: FIRStorageReference {
        return _REF_GAME_IMAGES
    }
    
    var REF_PROF_PICS: FIRStorageReference {
        return _REF_PROF_PICS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, AnyObject>) {
        REF_USERS.child(uid).child("profile").updateChildValues(userData)
        //if uid dosn't exist in database, it will create a new one for the uid
    }
    
    
    
}
