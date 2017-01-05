//
//  Geofence.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 05/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreLocation

public enum GeofenceMonitoringMode {
    case Entering
    case Exiting
}

public struct Geofence {
    let coordinate: CLLocationCoordinate2D
    let radius: Int
    let monitoringMode: GeofenceMonitoringMode
}
