//
//  DB.swift
//  NotePad_Try
//
//  Created by Vanessa Mendoza on 2016-08-07.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import Foundation
import SQLite

class DB {
    var conn: Connection?
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            self.conn = try Connection("\(path)/db.sqlite3")
            createTables()
        } catch { print("Catch connection") }
    }
    
    fileprivate func createTables () {
        do {
            try conn!.run(Notes.create())
            try conn!.run(Photos.create())
        } catch { print("Catch create tables") }
    }
}
