//
//  GeofenceMonitoring.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 11/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreLocation

class GeofenceMonitoring {
    
    private let locationManager = CLLocationManager()
    
    
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
