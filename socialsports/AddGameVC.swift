//
//  AddGameVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 1/2/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import LocationPickerViewController
import Firebase
import SwiftKeychainWrapper

class AddGameVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationPickerDelegate, LocationPickerDataSource{
    
    @IBOutlet weak var titleField: FancyField!
    @IBOutlet weak var maxPlayersField: FancyField!
    @IBOutlet weak var dateLbl: FancyLabel!
    @IBOutlet weak var timeLbl: FancyLabel!
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var locationLbl: FancyLabel!
    @IBOutlet weak var descriptionField: FancyField!
    
    var current = Date()
    var imagePicker: UIImagePickerController!
    var selectedImage = false
    private var latitude: Double!
    private var longitude: Double!
    
    var historyLocationList: [LocationItem] {
        get {
            if let locationDataList = UserDefaults.standard.array(forKey: "HistoryLocationList") as? [Data] {
                // Decode NSData into LocationItem object.
                return locationDataList.map({ NSKeyedUnarchiver.unarchiveObject(with: $0) as! LocationItem })
            } else {
                return []
            }
        }
        set {
            // Encode LocationItem object.
            let locationDataList = newValue.map({ NSKeyedArchiver.archivedData(withRootObject: $0) })
            UserDefaults.standard.set(locationDataList, forKey: "HistoryLocationList")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Show Location Picker via push segue.
        // LocationPicker in Storyboard.
        if segue.identifier == "goToLocationPicker" {
            let locationPicker = segue.destination as! LocationPicker
            // User delegate and dataSource.
            locationPicker.delegate = self
            locationPicker.dataSource = self
            locationPicker.isAlternativeLocationEditable = true
        }
    }
    
    // Location Picker Delegate
    
    func locationDidSelect(locationItem: LocationItem) {
        print("Select delegate method: " + locationItem.name)
        dismiss(animated: true, completion: nil)
    }
    
    func locationDidPick(locationItem: LocationItem) {
        showLocation(locationItem: locationItem)
        storeLocation(locationItem: locationItem)
    }
    
    
    
    // Location Picker Data Source
    
    func numberOfAlternativeLocations() -> Int {
        return historyLocationList.count
    }
    
    func alternativeLocation(at index: Int) -> LocationItem {
        return historyLocationList.reversed()[index]
    }
    
    func commitAlternativeLocationDeletion(locationItem: LocationItem) {
        historyLocationList.remove(at: historyLocationList.index(of: locationItem)!)
    }
    
    func showLocation(locationItem: LocationItem) {
        locationLbl.text = locationItem.name
        latitude = locationItem.coordinate?.latitude
        longitude = locationItem.coordinate?.longitude
        //locationItem.formattedAddressString
    }
    
    func storeLocation(locationItem: LocationItem) {
        if let index = historyLocationList.index(of: locationItem) {
            historyLocationList.remove(at: index)
        }
        historyLocationList.append(locationItem)
    }
    
    //ImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage { //making sure that it returns an image, check if its an image
            imageAdd.image = image
            selectedImage = true
        } else {
            print("DING: A Valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func dismissBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showDateTimePicker(sender: AnyObject) {
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(selected: current, minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.doneButtonTitle = "DONE"
        picker.todayButtonTitle = "Today"
        picker.completionHandler = { date in
            self.current = date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY"
            self.dateLbl.text = formatter.string(from: date)
            let timeFormat = DateFormatter()
            timeFormat.dateFormat = "HH:mm"
            self.timeLbl.text = timeFormat.string(from: date)
        }
    }
    
    @IBAction func createGameBtnPressed(_ sender: Any) {
        guard let title = titleField.text, title != "" else {
            print("DING: Title must be entered")
            return
        }
        //image
        guard let image = imageAdd.image, selectedImage == true else {
            print("DING: Image must be added")
            return
        }
        guard let date = dateLbl.text, date != "" else {
            print("DING: Date must be entered")
            return
        }
        guard let time = timeLbl.text, time != "" else {
            print("DING: Time must be entered")
            return
        }
        guard let location = locationLbl.text , location != "" else {
            print("DING: Location must be entered")
            return
        }
        guard let maxPlayers = maxPlayersField.text, maxPlayers != "" else {
            print("DING: Max players must be entered")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(image, 0.2) { //compress the image
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_GAME_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("DING: Unable to upload image to Firebase storage")
                } else {
                    print("DING: Successfully upload image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
                
            }
        }
        
        
    }
    
    func postToFirebase(imgUrl: String) {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        
        let post: Dictionary<String, AnyObject> = [
            "title": titleField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "date": dateLbl.text! as AnyObject,
            "maxppl": maxPlayersField.text! as AnyObject,
            "time": timeLbl.text! as AnyObject,
            "description": descriptionField.text! as AnyObject,
            "creator": uid! as AnyObject,
            "attendance": 1 as AnyObject
        ]
        
        let attending: Dictionary<String, Bool> = [
            "\(uid!)": true
        ]
        
        let location: Dictionary<String, AnyObject> = [
            "name": locationLbl.text! as AnyObject,
            "longitude": longitude as AnyObject,
            "latitude": latitude as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_GAMES.childByAutoId()
        firebasePost.setValue(post)
        firebasePost.child("attending").setValue(attending)
        firebasePost.child("location").setValue(location)
        selectedImage = false
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    

    
}
