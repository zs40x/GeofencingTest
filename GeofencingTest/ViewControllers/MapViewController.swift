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
    fileprivate var mapLongPressGestureRecognizer: UILongPressGestureRecognizer?
    fileprivate var coordinateForGeofenceDetailView: CLLocationCoordinate2D?
    fileprivate let geofenceService: GeofenceService = UserDefaultsGeofenceService()
    fileprivate let geofenceMonitoring = GeofenceMonitoring()
    
    fileprivate var isTrackingLocation = true
    fileprivate var geofencesWithOverlays = [Geofence:(MKAnnotation,MKCircle)]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonTrackLocation: UIBarButtonItem!
    @IBOutlet weak var segmentedCtrlMapType: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeMapView()
        initiaizeLocationManager()
        
        displayAndRegisterGeofences()
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
    
    @IBAction func actionSegmentedCtrlMapType(_ sender: Any) {
        
        switch segmentedCtrlMapType.selectedSegmentIndex {
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    func mapLongTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        guard gestureReconizer.state == .ended else { return }
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        coordinateForGeofenceDetailView = coordinate
        performSegue(withIdentifier: "showGeofenceViewController", sender: self)
    }
    
    
    private func initializeMapView() {
        
        mapLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapLongTap))
        mapLongPressGestureRecognizer?.minimumPressDuration = CFTimeInterval.init(1)
        mapView.addGestureRecognizer(mapLongPressGestureRecognizer!)
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
        mapCamera.altitude = 3000
    }
    
    fileprivate func displayAndRegisterGeofences() {
        
        displayGeofences()
        monitorGeofences()
    }
    
    private func initiaizeLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func displayGeofences() {
        
        let geofences = geofenceService.allGeofences()
        
        geofencesWithOverlays.forEach { (key: Geofence, value: (pin: MKAnnotation, radiusCircle: MKCircle)) in
            mapView.removeAnnotation(value.pin)
            mapView.remove(value.radiusCircle)
        }
        geofencesWithOverlays.removeAll()
        
        geofences.forEach { (geofence) in
            
            let pin = MKPointAnnotation()
            pin.coordinate = geofence.coordinate
            mapView.addAnnotation(pin)
            
            let radiusCircle = MKCircle(center: geofence.coordinate, radius: Double(geofence.radius))
            mapView.add(radiusCircle)
            
            geofencesWithOverlays[geofence] = (pin, radiusCircle)
        }
    }
    
    private func monitorGeofences() {
        
        let geofences = geofenceService.allGeofences()
        
        geofences.forEach { (geofence) in
            geofenceMonitoring.startGeofenceMonitoring(geofence)
        }
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else { return }
        
        isTrackingLocation = false
        mapView.setCenter(annotation.coordinate, animated: true)
        
        let tappedGeofences: [Geofence] =
            geofencesWithOverlays.flatMap {
                (key: Geofence, value: (pin: MKAnnotation, radiusCircle: MKCircle)) in
            
                if key.coordinate == annotation.coordinate {
                    return key
                }
                return nil
            }
        
        guard let firstTappedGeofence = tappedGeofences.first else { return }
        
        
        /*let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "geofencePopoverView")
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.preferredContentSize = CGSize(width: 300, height: 300)

        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = view // button
        popController.popoverPresentationController?.sourceRect = view.frame
        
        // present the popover
        self.present(popController, animated: true, completion: nil)*/
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let customAnnotationViewIdentifier = "MyAnnotation"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier)
        if pin == nil {
            pin = CustomAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
        } else {
            pin?.annotation = annotation
        }
        return pin
    }
}

extension MapViewController: GeofenceDetailDelegte {
    
    func saveGeofence(geofence: Geofence) {
        
        NSLog("MapViewController-GeofenceDetailDelegate.saveGeofence(\(geofence))")
        
        geofenceService.newGeofeofence(geofence)
        
        displayAndRegisterGeofences()
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
