//
//  GeofenceViewController.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 02/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

class GeofenceViewController : UIViewController {
    
    @IBOutlet weak var sliderRadius: UISlider!
    @IBOutlet weak var labelRadius: UILabel!
    @IBOutlet weak var segmentsMonitoringMode: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionNavBarBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionRadiusSliderValueChanged(_ sender: Any) {
    }
}
