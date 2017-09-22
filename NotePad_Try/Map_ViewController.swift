//
//  Map_ViewController.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-08-02.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import UIKit
import MapKit


class Map_ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var ann = MKPointAnnotation()
    override func viewDidLoad() {
        super.viewDidLoad()
        for subAnnot in self.map.annotations{
            map.removeAnnotation(subAnnot)
        }
        if ann.title != "" {
        self.map.centerCoordinate = (self.ann.coordinate)
        self.map.addAnnotation(self.ann)
        }
        // Centers, zooms and displays the region:
        let regionRadius: CLLocationDistance = 200
        let cordinateZoom = MKCoordinateRegionMakeWithDistance((self.ann.coordinate), regionRadius * 2.0, regionRadius * 2.0)
        self.map.setRegion(cordinateZoom, animated: true)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
