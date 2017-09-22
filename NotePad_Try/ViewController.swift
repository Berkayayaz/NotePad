//
//  ViewController.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-07-27.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var sortButton: UIBarButtonItem!
  //  @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTable: UITableView!
    var note_array = [Note]()
    var temp_note_array = [Note]()
    var selectedIndex:Int?
    var selectedNote:Note?
    var sortTable = "time"
    var searchActive = false
    var tab = UIGestureRecognizer()
    var db: DB?
    var dataSource = [Note]()
    var filteredDataSource = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        myTable.delegate = self
        myTable.dataSource = self
       // searchBar.delegate = self
        db = DB()
        dataSource = Notes.getNotes(db!)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:0.47, green:0.27, blue:0.67, alpha:1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.47, green:0.27, blue:0.67, alpha:1.0)
        //self.myTable.backgroundColor = UIColor(red:1.00, green:0.99, blue:1.00, alpha:1.0)
      /*
        //TEST
        let calendar = Calendar.current
        let yesterday = (calendar as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])
        let today = Date()
        let twodaysago = (calendar as NSCalendar).date(byAdding: .day, value: -6, to: Date(), options: [])
        
      */
        
        // Sort List
         self.dataSource = self.dataSource.sorted { $0.date < $1.date }
         sortButton.title = "Sort(Time)"


    }
    // UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        //CHECK TOUCH LOCATION IF IT IS INSIDE MY TABLE (I THINK DOESN'T WORK)
        if touch.view != nil && touch.view!.isDescendant(of: self.myTable) {
            return false
        }
        return true
    }
 
    
    //Search Bar functions
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredDataSource = self.dataSource.filter({( note : Note) -> Bool in
           
            return note.title.lowercased().contains(searchText.lowercased())
        })
        myTable.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredDataSource = dataSource.filter({( note : Note) -> Bool in
            let tmp: NSString = note.title as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filteredDataSource.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.myTable.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func convertDateFormater(_ date: Date) -> String {
        
        let calendar = Calendar.current
        let yesterday = (calendar as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])
        if calendar.isDateInToday(date){
     //       yesterday == date
            
            return "Today"
        }
        else if (calendar.isDateInYesterday(date)){
            return "Yesterday"
        }
        else{
        //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
        }
    }
    
    func dayCheck(_ date: String) -> String {
        
        let calendar = Calendar.current
        
        let timeStamp = dateFormatter.date(from: date)
        if calendar.isDateInToday(timeStamp!){
           
            
            return "Today"
        }
        else if (calendar.isDateInYesterday(timeStamp!)){
            return "Yesterday"
        }
        else{
            //
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy"
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            
            
            return date
        }
    }
    @IBAction func sortPressed(_ sender: UIBarButtonItem) {
        if searchActive{
     /*       if searchBar.text != ""{
            if self.sortTable == "time"
            {
                self.sortTable = "title"
                self.filteredDataSource = self.filteredDataSource.sorted { $0.title < $1.title }
                sortButton.title = "Sort(A-Z)"
                
                
            }
            else{
                self.sortTable = "time"
                self.filteredDataSource = self.filteredDataSource.sorted { $0.date < $1.date  }
                sortButton.title = "Sort(Date)"

            }
        }
        }
        else{
   */
        
        if self.sortTable == "time"
        {
                self.sortTable = "title"
                self.dataSource = self.dataSource.sorted { $0.title < $1.title }
                sortButton.title = "Sort(A-Z)"

          
            
        }
        else{
                self.sortTable = "time"
                self.dataSource = self.dataSource.sorted { $0.date < $1.date  }
                sortButton.title = "Sort(Date)"

            }
        }
        self.myTable.reloadData()
        
    }

    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredDataSource.count
        }
        else{
            return dataSource.count
        }
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! Note_TableViewCell
        if searchActive {
            let dates = (dataSource[indexPath.row].date).components(separatedBy: ", ")
            cell.titleLabel.text = filteredDataSource[indexPath.row].title
            cell.timeLabel.text = dates[1]
            cell.dateLabel.text = dates[0]
        }
        else{
            
            let dates = (dataSource[indexPath.row].date).components(separatedBy: ", ")
            cell.titleLabel.text = dataSource[indexPath.row].title
            cell.timeLabel.text = dates[1]
            cell.dateLabel.text = dates[0]
        }
        return cell
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /*   if searchActive {
           if searchBar.text == ""{
                self.selectedIndex = indexPath.row
                self.selectedNote = self.dataSource[indexPath.row]
            }
            else{
 
            self.selectedIndex = indexPath.row
            self.selectedNote = self.filteredDataSource[indexPath.row]
            }
        }
         else{
  */
            self.selectedIndex = indexPath.row
            self.selectedNote = self.dataSource[indexPath.row]
           
        
       self.performSegue(withIdentifier: "cellGoToNoteDetails", sender: self)
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //if !searchActive {
            if editingStyle == .delete{
                Notes.delete(db!, id: dataSource[indexPath.row].noteID)
                self.dataSource.remove(at: indexPath.row)
        }
        /*    }
        } else {
            if editingStyle == .delete{
                let noteId = filteredDataSource[indexPath.row].noteID
                Notes.delete(db!, id: noteId)
                self.filteredDataSource.remove(at: indexPath.row)
                
                let index = dataSource.index() { item in
                    item.noteID == noteId
                }
                
                if let indexInList = index {
                    self.dataSource.remove(at: indexInList)
                }
                
            }
           
        }
 */
         self.myTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = UIColor.clearColor()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellGoToNoteDetails"{
            let vc = segue.destination as! NoteDetails_ViewController
            vc.selectedNote = self.selectedNote
            vc.registeredNote = true
        }
    }
//    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
//    {
//        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
//        return orientation
//    }
//    
//    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
//    {
//        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation)
//        {
//            let bounds:CGRect = UIScreen.mainScreen().bounds
//            let width:CGFloat = bounds.size.width
//            let height:CGFloat = bounds.size.height + (navigationController?.navigationBar.frame.height)!
//            self.myTable.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
//            
//        }
//    }


}

