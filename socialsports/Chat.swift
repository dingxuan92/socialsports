//
//  Chat.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 8/3/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import Foundation

class Chat {
    private var _gameKey: String!
    private var _uid: String!
    private var _message: String!
    private var _timeStamp: String!
    
    var gameKey: String {
        return _gameKey
    }
    
    var uid: String {
        return _uid
    }
    
    var message: String {
        return _message
    }
    
    var timeStamp: String {
        return _timeStamp
    }
    
    init(gameKey: String,  uid: String) {
        _gameKey = gameKey
        _uid = uid
    }
    
    init(chatData: Dictionary<String, AnyObject>) {
        if let uid = chatData["uid"] as? String {
            _uid = uid
        }
        if let message = chatData["message"] as? String {
            _message = message
        }
        if let time = chatData["timeStamp"] as? String {
            _timeStamp = time
        }
    }
}
