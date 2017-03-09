//
//  Game.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 27/1/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import Foundation
import Firebase

class Game {
    
    private var _title: String!
    private var _likes: Int!
    private var _imageUrl: String!
    private var _gameKey: String!
    private var _attendance: Int!
    private var _creator: String!
    private var _description: String!
    private var _location: String!
    private var _maxppl: String!
    private var _date: String!
    private var _time: String!
    private var _timeStamp: String!
    private var _gameRef: FIRDatabaseReference!
    
    var title: String {
        return _title
    }
    
    var likes: Int {
        return _likes
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var attendance: Int {
        return _attendance
    }
    
    var creator: String {
        return _creator
    }
    
    var description: String {
        return _description
    }
    
    var location: String {
        return _location
    }
    
    var maxppl: String {
        return _maxppl
    }
    
    var gameKey: String {
        return _gameKey
    }
    
    var date: String {
        return _date
    }
    
    var time: String {
        return _time
    }
    
    var timeStamp: String {
        return _timeStamp
    }
    
    init(title: String, likes: Int, imageUrl: String) {
        self._title = title
        self._likes = likes
        self._imageUrl = imageUrl
    }
    
    init(gameKey: String, postData: Dictionary<String, AnyObject>) {
        self._gameKey = gameKey
        
        if let title = postData["title"] as? String {
            self._title = title
        }
        
        if let description = postData["description"] as? String {
            self._description = description
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let maxppl = postData["maxppl"] as? String {
            self._maxppl = maxppl
        }
        
        if let attendance = postData["attendance"] as? Int {
            self._attendance = attendance
        }
        
        if let creator = postData["creator"] as? String {
            self._creator = creator
        }
        
        if let location = postData["location"] as? Dictionary<String, AnyObject> {
            if let loc = location["name"] as? String {
                self._location = loc
            }
        }
        
        if let date = postData["date"] as? String {
            self._date = date
        }
        
        if let time = postData["time"] as? String {
            self._time = time
        }
        
        if let timeStamp = postData["timeStamp"] as? String {
            self._timeStamp = timeStamp
        }
        
        _gameRef = DataService.ds.REF_GAMES.child(gameKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _gameRef.child("likes").setValue(_likes)
    }
}
