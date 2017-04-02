//
//  MapVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 10/2/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var userName: UILabel!
    
    let locationManager = CLLocationManager()
    
    private var mapHasCenteredOnce = false
    private var geoFire: GeoFire!
    private var geoFireRef: FIRDatabaseReference!
    private var gameRef: FIRDatabaseReference!
    private var gameTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = DataService.ds.REF_MAP
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        gameRef = DataService.ds.REF_GAMES
        
        if let user = FIRAuth.auth()?.currentUser {
            if let photoURL = user.photoURL {
                let data = NSData(contentsOf: photoURL)
                profileImg.image = UIImage(data: data as! Data)
            }
            if let name = user.displayName {
                userName.text = name
            }
        }

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    private func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //authorizedWhenInUse does not drain user battery
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        let annoIdentifier = "Game"
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "myLocation")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        } else {
            
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av // in case the dequeue fails, create a default one
        }
        
        //customise the annotationView
        if let annotationView = annotationView, let anno = annotation as? GameAnnotation {
            
            annotationView.canShowCallout = true // have to set title if not will crash
            annotationView.image = UIImage(named: "\(anno.colorPin)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named:"map-1"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
    }
    
    
    private func showSightingsOnMap(location: CLLocation) {
        
        let circleQuery = geoFire!.query(at:location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            //Also, as when the app loads for the first time, the this will run and cycle through every single annotation on the map, with its specific geographic location and going to add it as annotation
            
            if let key = key, let location = location {
                
                self.getGameTitle(key: key, completion: { (title) in
                    if title.characters.count > 0 {
                        print("Title found \(title)")
                        let anno = GameAnnotation(coordinate: location.coordinate, gameKey: title)
                        self.mapView.addAnnotation(anno)
                    }
                    else {
                        print("Title Not Found")
                    }
                })
                
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? GameAnnotation {
            
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            
            let destination = MKMapItem(placemark: place)
            destination.name = "Game Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
        
    }
    
    private func getGameTitle(key: String, completion:@escaping (String) -> ()) {
        self.gameRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let value = snapshot.value as? NSDictionary
            if let gameTitle = value?["title"] as? String {
                completion(gameTitle)
            }
            else {
                completion("")
            }
        })
    }
    
    @IBAction private func FeedBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    @IBAction private func goToAddGame(_ sender: Any) {
        performSegue(withIdentifier: "goToAddGame", sender: nil)
    }
    
    @IBAction private func profileButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "MapToProfile", sender: nil)
    }
}
