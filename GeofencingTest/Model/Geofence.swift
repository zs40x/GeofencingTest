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
    
    init?(json : String) {
        guard let data = json.data(using: .utf8),
                let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String],
                let longiture = jsonDict?["longitude"],
                let latitude = jsonDict?["latitude"],
                let radius = jsonDict?["radius"],
                let monitoringMode = jsonDict?["monitoringMode"]
            else { return nil }
        
        self.coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longiture) ?? 0)
        self.radius = Int(radius) ?? 0
        self.monitoringMode = monitoringMode == "0" ? .Entering : .Exiting
    }
    
    var jsonRepresentation : String {
        let jsonDict =
            [
                "latitude" : coordinate.latitude,
                "longitude" : coordinate.longitude,
                "radius" : radius,
                "monitoringMonde" : monitoringMode.rawValue
            ]
        
        if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
            let jsonString = String(data:data, encoding:.utf8) {
            return jsonString
        } else { return "" }
    }
}
