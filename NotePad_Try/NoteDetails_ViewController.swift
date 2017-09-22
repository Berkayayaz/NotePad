//
//  NoteDetails_ViewController.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-07-27.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBookUI
import MobileCoreServices
import SQLite

class NoteDetails_ViewController: UIViewController, CLLocationManagerDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate  {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noteTextBox: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    var annloc = CLLocation()
    fileprivate let locationManager = CLLocationManager()
    var location = String()
    var textField = UITextField()
    var photos = [UIImage]()
    var selectedNote:Note?
    var registeredNote = false
    var textDocumentProxy: NSObject!
    var annot = MKPointAnnotation()
    var image: UIImage?
    var imageSize = CGSize(width: CGFloat(80), height: CGFloat(80))
    var selectedRow:Int?
    
    var imagePath: String?
    var imageSource = [String]()
    var db: DB?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITextViewDelegate
        noteTextBox.delegate = self
        
        db = DB()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:0.47, green:0.27, blue:0.67, alpha:1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.47, green:0.27, blue:0.67, alpha:1.0)
        
        //Title textfield
        textField.delegate = self;
        let size = navigationController?.navigationBar.frame.size
        let width = (size?.width)! / 3
        let height = (size?.height)! - 4
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: height))
        textField.text = "Title"
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.textColor = UIColor.white
        textField.textAlignment = .center
        self.navigationItem.titleView = textField
        
        var noteID: Int64 = Int64()
        
        if selectedNote != nil && self.registeredNote{
            textField.text = selectedNote?.title
            noteTextBox.text = selectedNote?.textContent
            noteID = (selectedNote?.noteID)!
            imageSource = Photos.getPhotos(db!, noteId: noteID).map() { photo in
                return photo.photo
                
            }
//            self.photos = (selectedNote?.photos)!
            
            let rawLoc = CLLocation(latitude: self.selectedNote!.latitude, longitude: self.selectedNote!.longitude)
              geoCoder(rawLoc)
           self.locationLabel.text = selectedNote?.address
            self.annot = createAnnotation(self.selectedNote!.latitude, long: self.selectedNote!.longitude, location: self.selectedNote!.address, title: self.selectedNote!.title)
        }
        
        
        //Core Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        //CollectionView
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.white
        
    }

   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            noteTextBox.resignFirstResponder()
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Change return button to done
//        func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//                    if (text == "\n") {
//                        noteTextBox.resignFirstResponder()
//                    }
//                    return true
//        }
   
//    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        let errorType = error._code == CLError.Code.denied.rawValue
            ? "Access Denied": "Error \(error._code)"
        let alertController = UIAlertController(title: "Location Manager Error",
                                                message: errorType, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel,
                                     handler: { action in })
        alertController.addAction(okAction)
        present(alertController, animated: true,
                              completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            self.annloc = newLocation
            self.geoCoder(newLocation)
            
        }
    }
    
    func geoCoder(_ newLocation: CLLocation){
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
            if newLocation.horizontalAccuracy < 0 {
                // invalid accuracy
                return
            }
            
            if newLocation.horizontalAccuracy > 100 ||
                newLocation.verticalAccuracy > 50 {
                // accuracy radius is so large, we don't want to use it
                return
            }
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            self.locationManager.stopUpdatingLocation()
            // Address dictionary
            
          //  print(placeMark.addressDictionary)
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName)
                self.location = locationName as String
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street)
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country)
            }
            
        })

    }


    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        
        // FIXME:
        //self.locationManager.startUpdatingLocation()
        print("############## LOCATION:" + location)
        self.locationLabel.text = location
        dismissKeyboard()
        
        if selectedNote != nil {
            let id = selectedNote?.noteID
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            let now = dateformatter.string(from: Date())
            
            Notes.updateNote(db!, id: id!, data: [
                "title": textField.text! as AnyObject,
                "content": noteTextBox.text as AnyObject,
                "latitude": annloc.coordinate.latitude as Double as AnyObject,
                "longitude": annloc.coordinate.longitude as Double as AnyObject,
                "date": now as AnyObject,
                "address": location as AnyObject
                ])
            Notes.getNotes(db!)
            selectedNote?.title = textField.text!
            selectedNote?.textContent = noteTextBox.text
            selectedNote?.latitude = annloc.coordinate.latitude as Double
            selectedNote?.longitude = annloc.coordinate.longitude as Double
            selectedNote?.lastTime = Date()
            selectedNote?.address = location
            
            Photos.delete(db!, noteId: id!)
            for photo in imageSource {
                Photos.insert(db!, noteId: id!, photo: photo)
            }
            
            self.performSegue(withIdentifier: "goToTable", sender: self)
        } else {
            if !noteTextBox.text.isEmpty {
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = DateFormatter.Style.short
                dateformatter.timeStyle = DateFormatter.Style.short
                let now = dateformatter.string(from: Date())
                
                let noteId = Notes.insert(db!, data: [
                    "title": textField.text! as AnyObject,
                    "content": noteTextBox.text as AnyObject,
                    "latitude": annloc.coordinate.latitude as Double as AnyObject,
                    "longitude": annloc.coordinate.longitude as Double as AnyObject,
                    "date": now as AnyObject,
                    "address": location as AnyObject
                    ])
                Notes.getNotes(db!)
                
                for photo in imageSource {
                    Photos.insert(db!, noteId: noteId!, photo: photo)
                }
                
                self.performSegue(withIdentifier: "goToTable", sender: self)
            } else {
                
            }
        }
    }
    
    func createAnnotation(_ lat:Double,long:Double, location:String, title:String) -> MKPointAnnotation {
        
        let ann = MKPointAnnotation()
        
        ann.coordinate = CLLocationCoordinate2DMake(lat, long)
        ann.title = location
        ann.subtitle = title
        
        return ann
    }
    
    
    @IBAction func mapPressed(_ sender: UIButton) {
        if locationLabel.text == ""{
            let alertController = UIAlertController(title:"Map",
                                                    message: "There is no saved location.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            
        }
    
    else{ // FIXME:
            
            if selectedNote == nil && !registeredNote {
               
            
    self.annot = self.createAnnotation(self.annloc.coordinate.latitude,long: self.annloc.coordinate.longitude,location: self.location, title: self.textField.text!)
        }
        }
    }

    @IBAction func addPhotoPressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "Upload a Photo", preferredStyle: UIAlertControllerStyle.actionSheet)
        let takePhoto = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: {(actionSheet: UIAlertAction!) in (self.takePhoto())})
        let takeFromLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler: {(actionSheet: UIAlertAction!) in (self.uploadPhotoAction())})
        let cancel  = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(takeFromLibrary)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return  imageSource.count + 1
        return imageSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        
        selectedRow = indexPath.row
        performSegue(withIdentifier: "showToImageViewer", sender: self)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return imageSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)

        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        // FIXME:
        
        let image = UIImage(contentsOfFile: (imageSource[indexPath.row]))
        let imageView = UIImageView(image: image)
        imageView.frame.size = self.imageSize
        cell.addSubview(imageView)
    
        return cell
    }

    func uploadPhotoAction(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title:"Error accessing Library",
                                                    message: "Can't find Library.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func takePhoto(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
            
        } else {
            let alertController = UIAlertController(title:"Error accessing media",
                                                    message: "Unsupported media source.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
//        self.image = image
//        self.photos.append(image)
        
        var imageJPG: Data?
        
        //Save to photo album
        if picker.sourceType == UIImagePickerControllerSourceType.camera {
            imageJPG = UIImageJPEGRepresentation(image, 0.6)
        } else {
            imageJPG = UIImageJPEGRepresentation(image, 1.0)
        }
        
        if let image = imageJPG {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let randomName = Date().description
            let filePath = "\(path[0])/\(randomName).jpg"
            try? image.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            imagePath = filePath
            
            self.imageSource.append(imagePath!)
            print(filePath)
        }
        
        self.collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showToMap"{
            let vc:Map_ViewController = segue.destination as! Map_ViewController
            vc.ann = self.annot
        }
        if segue.identifier == "showToImageViewer"{
            let vc:ImageViewController = segue.destination as! ImageViewController
            vc.imageIndex = selectedRow!
            vc.imageArr = imageSource
        }
    }
 
    
}
