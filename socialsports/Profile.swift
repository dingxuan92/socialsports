//
//  Profile.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 4/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import Foundation
import Firebase

class Profile {
    
    private var _name: String!
    private var _imageUrl: String!
    private var _userKey: String!
    
    var name: String! {
        return _name
    }
    
    var imageUrl: String! {
        return _imageUrl
    }
    
    var userKey: String! {
        return _userKey
    }
    
    init(key: String) {
        self._userKey = key
    }
    
}
