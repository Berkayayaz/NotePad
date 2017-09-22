//
//  Photo.swift
//  NotePad_Try
//
//  Created by Vanessa Mendoza on 2016-08-08.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import Foundation

open class Photo {
    var id: Int64
    var noteID: Int64
    var photo: String
    var db: DB
    
    init() {
        id = Int64()
        noteID = Int64()
        photo = ""
        db = DB()
    }
    
    init(id: Int64, noteID: Int64, photo: String, db: DB) {
        self.id = id
        self.noteID = noteID
        self.photo = photo
        self.db = db
    }
}
