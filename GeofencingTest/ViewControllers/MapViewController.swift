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

class MapViewController: UIViewController {

    fileprivate let locationManager = CLLocationManager()
    fileprivate let mapCamera = MKMapCamera()
    fileprivate var cameraZoomInitialized = false
    fileprivate var mapLongPressGestureRecognizer: UITapGestureRecognizer?
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapLongPressGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapLongTap))
        mapView.addGestureRecognizer(mapLongPressGestureRecognizer!)
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
        
        mapCamera.altitude = 1000
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraZoomInitialized = false
    }
    
    func mapLongTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        performSegue(withIdentifier: "showGeofenceViewController", sender: self)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        NSLog("Map is now centered on \(userLocation)")
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedAlways else {
            NSLog("ViewController.locationManager.didChangeAutorization -> not authorized!")
            return
        }
        
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let lastLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            [unowned self, coordinate = lastLocation.coordinate] in
         
            
            if !self.cameraZoomInitialized {
                self.mapView.setCamera(self.mapCamera, animated: false)
            }
            
            self.mapView.setCenter(coordinate, animated: self.cameraZoomInitialized)
        
            self.cameraZoomInitialized = true
        }
    }
}
