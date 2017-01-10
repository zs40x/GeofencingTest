//
//  GeofenceService.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 10/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol GeofenceService {
    func allGeofences() -> [Geofence]
    func newGeofeofence(_ geofence: Geofence)
}

class UserDefaultsGeofenceService: GeofenceService {
    
    func allGeofences() -> [Geofence] {
    
    }
    
    func newGeofeofence(_ geofence: Geofence) {
    
    }
}
