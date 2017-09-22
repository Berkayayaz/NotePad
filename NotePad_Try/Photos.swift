//
//  Photos.swift
//  NotePad_Try
//
//  Created by Vanessa Mendoza on 2016-08-07.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import Foundation
import SQLite

class Photos {
    let table = Table("photos")
    
    let id = Expression<Int64>("id")
    let note_id = Expression<Int64>("note_id")
    let photo = Expression<String>("photo")
    
    static let instance = Photos()
    
    static func create() -> String {
        let notes = Notes()
        return instance.table.create(ifNotExists: true) { t in
            t.column(instance.id, primaryKey: true)
            t.column(instance.note_id, references: notes.table, notes.id)
            t.column(instance.photo)
        }
    }
    
    static func insert(_ db: DB, noteId: Int64, photo: String) {
        do {
            try db.conn!.run(instance.table.insert(
                instance.note_id <- noteId,
                instance.photo <- photo
                ))
        } catch {
            print("Error saving record")
        }
    }
    
    static func getPhotos(_ db: DB, noteId: Int64) -> [Photo]{
        var results = [Photo]()
        let photos = instance.table.filter(instance.note_id == noteId)
        do{
            for photo in try db.conn!.prepare(photos) {
                print("id: \(photo[instance.id]), noteID: \(photo[instance.note_id]), photo: \(photo[instance.photo])")
                var result = Photo()
                result.id = photo[instance.id]
                result.noteID = photo[instance.note_id]
                result.photo = photo[instance.photo]
                results.append(result)
            }
        } catch{ print("Error retrieving record") }
        
        return results
    }
    
    static func delete(_ db: DB, noteId: Int64) {
        do {
            let photos = instance.table.filter(instance.note_id == noteId)
            try db.conn!.run(photos.delete())
        } catch { print("Error updating record") }
    }
    
    static func delete(_ db: DB, photo: String) {
        do {
            let photos = instance.table.filter(instance.photo == photo)
            try db.conn!.run(photos.delete())
        } catch { print("Error updating record") }
    }
}
