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
    
    var title: String {
        return _title
    }
    
    var likes: Int {
        return _likes
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var gameKey: String {
        return _gameKey
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
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
    }
}
