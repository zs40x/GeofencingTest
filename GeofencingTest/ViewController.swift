//
//  ViewController.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 01/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    fileprivate let locationManager = CLLocationManager()
    fileprivate let mkMapCamera = MKMapCamera()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true // ToDo: only when authorization granted
        mapView.setCamera(mkMapCamera, animated: false)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else { return }
        
        let mapRegion = MKCoordinateRegion(center: lastLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(mapRegion, animated: true)
        
        //mapView.setCenter(lastLocation.coordinate, animated: true)
        //mkMapCamera.centerCoordinate = lastLocation.coordinate
    }
}

