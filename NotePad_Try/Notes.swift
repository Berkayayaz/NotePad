//
//  Notes.swift
//  NotePad_Try
//
//  Created by Vanessa Mendoza on 2016-08-07.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import Foundation
import SQLite

class Notes {
    let table = Table("notes")
    
    let id = Expression<Int64>("id")
    let title = Expression<String>("title")
    let content = Expression<String>("content")
    let latitude = Expression<Double>("latitude")
    let longitude = Expression<Double>("longitude")
    let date = Expression<String>("date")
    let address = Expression<String>("address")
    
    static let instance = Notes()
    
    static func create() -> String {
        return instance.table.create(ifNotExists: true) { t in
            t.column(instance.id, primaryKey: true)
            t.column(instance.title)
            t.column(instance.content)
            t.column(instance.latitude)
            t.column(instance.longitude)
            t.column(instance.date)
            t.column(instance.address)
        }
    }
    
   static func insert(_ db: DB, data: Dictionary<String, AnyObject>) -> Int64? {
        var rowId: Int64 = 0
    
        do {
            try rowId = db.conn!.run(instance.table.insert(
                instance.title <- (data["title"] as! String),
                instance.content <- (data["content"] as! String),
                instance.latitude <- (data["latitude"] as! Double),
                instance.longitude <- (data["longitude"] as! Double),
                instance.date <- (data["date"] as! String),
                instance.address <- (data["address"] as! String)
            ))
        } catch {
            print("Error saving record")
        }
    
        return rowId
        
    }
    
    static func getNotes(_ db: DB) -> [Note] {
        var results = [Note]()
        
        do {
            for note in try db.conn!.prepare(instance.table) {
                print("id: \(note[instance.id]), title: \(note[instance.title]), content: \(note[instance.content]), lat: \(note[instance.latitude]), long: \(note[instance.longitude]), date: \(note[instance.date])")
                var result = Note()
                result.noteID = note[instance.id]
                result.title = note[instance.title]
                result.textContent = note[instance.content]
                result.latitude = note[instance.latitude]
                result.longitude = note[instance.longitude]
                result.date = note[instance.date]
                result.address = note[instance.address]
                results.append(result)
            }
        } catch { print("Error retrieving record") }
        return results
    }
    
    static func updateNote(_ db: DB, id: Int64, data: Dictionary<String, AnyObject>) {
        do {
            let note = instance.table.filter(instance.id == id)
            try db.conn!.run(note.update(
                instance.title <- (data["title"] as! String),
                instance.content <- (data["content"] as! String),
                instance.latitude <- (data["latitude"] as! Double),
                instance.longitude <- (data["longitude"] as! Double),
                instance.date <- (data["date"] as! String),
                instance.address <- (data["address"] as! String)
            ))
        } catch { print("Error updating record") }
    }
    
    static func delete(_ db: DB, id: Int64) {
        do {
            Photos.delete(db, noteId: id)
            let notes = instance.table.filter(instance.id == id)
            try db.conn!.run(notes.delete())
        } catch { print("Error updating record") }
    }
}
