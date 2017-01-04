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
    
    @IBOutlet weak var labelRadius: UILabel!
    @IBOutlet weak var sliderRadius: UISlider!
    @IBOutlet weak var segmentsMonitoringMode: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeMapWithCoordinate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initializeMapWithCoordinate() {
        
        guard let coordinate = coordinate else { return }
        
        mapView.centerCoordinate = coordinate
    }
    
    
    @IBAction func actionNavigationBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actionNavBarBack(_ sender: Any) {
        
    }

    @IBAction func actionSliderRadiusValueChanged(_ sender: Any) {
        labelRadius.text = String(Int(sliderRadius.value))
    }
}

