
/*
import Foundation
import UIKit
import MapKit

class SQLiteDatabase {
    
    static let NOTE_TABLE_NAME = "NOTE"
    static let IMAGE_TABLE_NAME = "IMAGE"
    var database:COpaquePointer = nil
    var tempImageArray = [UIImage]()
    var note_list = [Note]()
    
    init() {
        
    }
    
    func createNoteTable(tableName: String) {
        var result = sqlite3_open(dataFilePath(), &database)
        
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        let createSQL = "CREATE TABLE IF NOT EXISTS " + tableName + " " +
            "(ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "TITLE TEXT, " +
            "TEXTCONTENT TEXT, " +
            "TIME DATE, " +
            "LONGITUDE DOUBLE, " +
            "LATITUDE DOUBLE);"
        
        NSLog("SQLite: creating table sql=\"" + createSQL + "\"")
        
        var errMsg:UnsafeMutablePointer<Int8> = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            NSLog("SQLite: Failed to create Note table")
            return
        }
        
        NSLog("SQLite: database Note table created")
    }
    func createImageTable(tableName: String) {
        var result = sqlite3_open(dataFilePath(), &database)
        
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        let createSQL = "CREATE TABLE IF NOT EXISTS " + tableName + " " +
            "(ID INTEGER PRIMARY KEY, " +
            "IMAGEVALUE BLOB, " +
            "NOTEID INTEGER, " +
            "FOREIGN KEY (NOTEID) REFERENCES \(SQLiteDatabase.NOTE_TABLE_NAME)(ID));"
        
        NSLog("SQLite: creating table sql=\"" + createSQL + "\"")
        
        var errMsg:UnsafeMutablePointer<Int8> = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            NSLog("SQLite: Failed to create Image table")
            return
        }
        
        NSLog("SQLite: database Image table created")
    }
    
    
    func readAllNotesWithPhotosByID() -> [Note] {
        
        // OR LEFT JOIN??
        let query = "SELECT ID, TITLE, TEXTCONTENT, TIME, LONGITUDE, LATITUDE FROM \(SQLiteDatabase.NOTE_TABLE_NAME); "
        var statement:COpaquePointer = nil
        
        
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                
                self.tempImageArray.removeAll()
                let noteID = Int(sqlite3_column_int(statement, 0))
                let rawTitle = sqlite3_column_text(statement, 1)
                let title = String.fromCString(UnsafePointer<CChar>(rawTitle))
                let rawTextContent = sqlite3_column_text(statement, 2)
                let textContent = String.fromCString(UnsafePointer<CChar>(rawTextContent))
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let rawTime = UnsafePointer<Int8>(sqlite3_column_text(statement, 3))
                let time = String.fromCString(rawTime)
 
                let titleString = String(UTF8String: title!)!
                let textContentString = String(UTF8String: textContent!)!
                let timeString = String(UTF8String: time!)!
                let longitude = Double(sqlite3_column_double(statement, 4))
                let latitude = Double(sqlite3_column_double(statement, 5))
                
                let queryImages = "SELECT IMAGEVALUE FROM \(SQLiteDatabase.IMAGE_TABLE_NAME) WHERE  \(SQLiteDatabase.IMAGE_TABLE_NAME).CODEID = \(noteID); "
                var statementImages:COpaquePointer = nil
                
               
                if sqlite3_prepare_v2(database, queryImages, -1, &statementImages, nil) == SQLITE_OK {
                    while sqlite3_step(statementImages) == SQLITE_ROW {
                
                let blob = sqlite3_column_blob(statementImages, 0)
                if blob != nil {
                    
                let size = sqlite3_column_bytes(statementImages, 0)
              let  imageData = NSData(bytes: blob, length: Int(size))
                    let image = UIImage(data: imageData)
                    self.tempImageArray.append(image!)
                        }
                          sqlite3_finalize(statementImages)
                    }
               
 
                let note = Note(noteID: noteID, title: titleString, textContent: textContentString, photos: tempImageArray, lastTime: timeString, latitude: latitude, longitude: longitude)
                    
                    self.note_list.append(note)
                    
                    
                NSLog("SQLite: reading annotation item title=\(note.title), long=%f, lat=%f",
                      note.longitude, note.latitude)
            }
            sqlite3_finalize(statement)
        }
        }
        //sqlite3_close(database)
        return self.note_list
    
    }
    
    func clearAnnotations() {
        let deleteSQL = "DELETE FROM \(SQLiteDatabase.NOTE_TABLE_NAME)"
        
        var errMsg:UnsafeMutablePointer<Int8> = nil
        let result = sqlite3_exec(database, deleteSQL, nil, nil, &errMsg)
        
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            NSLog("SQLite: Failed to delete table")
            return
        }
        
        NSLog("SQLite: database table deleted")
        
    }
    
    func createNote(note: Note) {
        NSLog("SQLite: saving Note...")
        
      
       
            let updateSQL = "INSERT INTO \(SQLiteDatabase.NOTE_TABLE_NAME) (TITLE, TEXTCONTENT, TIME, LONGITUDE, LATITUDE) " +
            "VALUES (?, ?, ?, ?);"
            
            var statement:COpaquePointer = nil
            
            if sqlite3_prepare_v2(database, updateSQL, -1, &statement, nil) == SQLITE_OK {
               
                let title = note.title as NSString
                sqlite3_bind_text(statement, 1, title.UTF8String, -1, nil)
                let textContent = note.textContent as NSString
                sqlite3_bind_text(statement, 2, textContent.UTF8String, -1, nil)
                let lastTime = note.lastTime as NSString
                sqlite3_bind_text(statement, 3, lastTime.UTF8String, -1, nil)
                sqlite3_bind_double(statement, 4, note.longitude)
                sqlite3_bind_double(statement, 5, note.latitude)
                
                //NSLog("SQLite: saving annotation")
                NSLog("SQLite: saving Note(title: \(title), long: %f, lat: %f)",
                      Double(note.longitude), Double(note.latitude))
            }
        
        let updateImageSQL = "INSERT INTO \(SQLiteDatabase.NOTE_TABLE_NAME) (TITLE, TEXTCONTENT, TIME, LONGITUDE, LATITUDE) " +
        "VALUES (?, ?, ?, ?);"
        
        var statement:COpaquePointer = nil
        
        if sqlite3_prepare_v2(database, updateSQL, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) != SQLITE_DONE {
                NSLog("SQLite: Error updating table")
                sqlite3_close(database)
                return
            }
            sqlite3_finalize(statement)
        
        }
    }
    
    func dataFilePath() -> String {
        let urls = NSFileManager.defaultManager().URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask)
        return urls.first!.URLByAppendingPathComponent("data.plist").path!
    }
    
}
*/
