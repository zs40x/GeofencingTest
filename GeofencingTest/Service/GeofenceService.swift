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
        
       guard let geofenceJsonStringArray = UserDefaults.standard.value(forKey: "geofences") as? [String] else {
            NSLog("No geofeonce in userDefaults found")
            return [Geofence]()
        }
            
        return geofenceJsonStringArray.flatMap({ Geofence(json: $0) })
    }
    
    func newGeofeofence(_ geofence: Geofence) {
    
    }
}
