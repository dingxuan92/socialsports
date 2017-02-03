//
//  AddGameVC.swift
//  socialsports
//
//  Created by Chan Ding Xuan on 1/2/17.
//  Copyright © 2017 Chan Ding Xuan. All rights reserved.
//

import UIKit
import LocationPickerViewController

class AddGameVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationPickerDelegate, LocationPickerDataSource{
    
    @IBOutlet weak var dateLbl: FancyLabel!
    @IBOutlet weak var timeLbl: FancyLabel!
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var locationLbl: FancyLabel! // not done yet
    
    var current = Date()
    var imagePicker: UIImagePickerController!
    var x = 0
    
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
    
    //# of players pickerView continue later
    

    
}
