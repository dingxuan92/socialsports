//
//  GameAnnotation.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 22/2/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class GameAnnotation: NSObject, MKAnnotation {
    internal var coordinate = CLLocationCoordinate2D()
    private var _colorPin: String
    internal var title: String?
    
    var colorPin: String {
        return _colorPin
    }
    
    init(coordinate: CLLocationCoordinate2D, gameKey: String) {

        self.coordinate = coordinate
        self._colorPin = "greenPin"
        self.title = gameKey
    
    }
    
}
