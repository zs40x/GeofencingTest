//
//  GeofenceViewController.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 03/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import UIKit
import MapKit

class GeofenceDetailViewController: UIViewController {
    
    public var coordinate: CLLocationCoordinate2D?
    private var circle: MKCircle?
    
    @IBOutlet weak var labelRadius: UILabel!
    @IBOutlet weak var sliderRadius: UISlider!
    @IBOutlet weak var segmentsMonitoringMode: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self

        initializeMapWithCoordinate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initializeMapWithCoordinate() {
        
        guard let coordinate = coordinate else { return }
        
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 2000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        updateRadiusOverlay()
    }
    
    
    @IBAction func actionNavigationBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actionNavBarBack(_ sender: Any) {
        
    }

    @IBAction func actionSliderRadiusValueChanged(_ sender: Any) {
        
        labelRadius.text = String(Int(sliderRadius.value))
        
        updateRadiusOverlay()
    }
    
    
    private func updateRadiusOverlay() {
        
        guard let coordinate = coordinate else { return }
        
        if let overlay = circle {
            mapView.remove(overlay)
        }
        
        circle = MKCircle(center: coordinate, radius: Double(sliderRadius.value))
        
        mapView.add(circle!)
    }
}

extension GeofenceDetailViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.0);
        circleRenderer.strokeColor = UIColor.gray.withAlphaComponent(0.9)
        circleRenderer.lineWidth = 2;
        circleRenderer.lineDashPattern = [2, 5]
        circleRenderer.alpha = 0.5;
        
        return circleRenderer
    }
}

