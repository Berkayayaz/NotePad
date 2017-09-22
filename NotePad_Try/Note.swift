//
//  Note.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-07-29.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


open class Note {
    
    var noteID:Int64
    var title:String
    var textContent:String
    var photos:[UIImage]
    var lastTime:Date
    var latitude:Double
    var longitude:Double
    var annotation:MKPointAnnotation?
    var saveStatus:Bool = false
    var address:String
    var date:String
    var db: DB?
    
    init(){
        noteID = Int64()
        title = ""
        textContent = ""
        photos = [UIImage]()
        lastTime = Date()
        self.latitude = Double()
        self.longitude = Double()
        address = ""
        date = ""
        
        db = DB()
        
    }
    
    init(noteID:Int64, title:String, textContent:String, photos:[UIImage],lastTime:Date,latitude:Double, longitude:Double, address:String, date: String, db:DB)
    {
        self.noteID = noteID
        self.title = title
        self.textContent = textContent
        self.photos = photos
        self.lastTime = lastTime
        self.latitude = latitude
        self.longitude = longitude
        self.saveStatus = true
        self.address = address
        self.date = date
        self.db = db
        self.annotation = self.createAnnotation()
    }
    
    
    open func createAnnotation() -> MKPointAnnotation {
        let annot = MKPointAnnotation()
        annot.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        annot.title = self.title
        
        return annot
    }
    
}
