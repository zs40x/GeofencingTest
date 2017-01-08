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
    fileprivate var coordinateForGeofenceDetailView: CLLocationCoordinate2D?
    
    fileprivate var isTrackingLocation = true
    private var geofences: [Geofence]?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonTrackLocation: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapLongPressGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapLongTap))
        mapView.addGestureRecognizer(mapLongPressGestureRecognizer!)
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
        mapCamera.altitude = 3000
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        loadAndDisplayGeofences()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraZoomInitialized = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let geofenceDetailViewController = segue.destination as? GeofenceDetailViewController {
            geofenceDetailViewController.coordinate = coordinateForGeofenceDetailView
            geofenceDetailViewController.geofenceDetailDelegate = self
        }
    }
    
    @IBAction func actionTrackLocation(_ sender: Any) {
    
        isTrackingLocation = isTrackingLocation ? false : true
    }
    
    
    func mapLongTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        coordinateForGeofenceDetailView = coordinate
        performSegue(withIdentifier: "showGeofenceViewController", sender: self)
    }
    
    private func loadAndDisplayGeofences() {
        
        guard let geofenceJsonString = UserDefaults.standard.value(forKey: "geofences") as? [String] else {
            NSLog("No geofeonce in userDefaults found")
            return
        }
        return
        /*guard let geofencesJson = geofenceJsonString.data(using: .utf8),
              let geofencesJsonArray = try? JSONSerialization.jsonObject(with: geofencesJson, options: []) as? [String]
            else {
                NSLog("Failed loading geofences")
                return
        }
        return
        let geofences =
            geofencesJsonArray.map { (geofenceJson) in Geofence(json: geofenceJson) }
        
        guard let geofence = Geofence(json: geofenceJsonString) else { return }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = geofence.coordinate
        mapView.addAnnotation(annotation)

        mapView.add(MKCircle(center: geofence.coordinate, radius: Double(geofence.radius)))
        
        startGeofenceMonitoring(geofence)*/
    }
    
    func startGeofenceMonitoring(_ geofence: Geofence) {
            
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            NSLog("Geofencing is not supported on this device!")
            return
        }
            
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            NSLog("Geofence monitoring not possible if the app has no access to the location")
            return
        }
            
        locationManager.startMonitoring(for: makeRegion(geofence: geofence))
            
        NSLog("Now monitoring region for geofence: \(geofence)")
    }
    
    private func makeRegion(geofence: Geofence) -> CLCircularRegion {
        
        let region = CLCircularRegion(center: geofence.coordinate, radius: Double(geofence.radius), identifier: geofence.identifier)
        
        region.notifyOnEntry = (geofence.monitoringMode == .Entering)
        region.notifyOnExit = !region.notifyOnEntry
        
        return region
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.fillColor = UIColor.green.withAlphaComponent(0.2);
        circleRenderer.strokeColor = UIColor.gray.withAlphaComponent(0.9)
        circleRenderer.lineWidth = 2;
        circleRenderer.lineDashPattern = [2, 5]
        circleRenderer.alpha = 0.5;
        
        return circleRenderer
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
        
        guard isTrackingLocation else { return }
        
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

extension MapViewController: GeofenceDetailDelegte {
    
    func saveGeofence(geofence: Geofence) {
        
        NSLog("MapViewController-GeofenceDetailDelegate.saveGeofence(\(geofence))")
        
        let geofencesJson = [geofence.jsonRepresentation]
        
        UserDefaults.standard.set(geofencesJson, forKey: "geofences")
    }
}
