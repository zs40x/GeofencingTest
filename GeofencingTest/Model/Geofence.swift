//
//  Geofence.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 05/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreLocation

public enum GeofenceMonitoringMode: Int {
    case Entering = 0
    case Exiting
}

public struct Geofence {
    let identifier: String
    let coordinate: CLLocationCoordinate2D
    let radius: Int
    let monitoringMode: GeofenceMonitoringMode
    
    init(identifier: String, coordinate: CLLocationCoordinate2D, radius: Int, monitoringMode: GeofenceMonitoringMode) {
        self.identifier = identifier
        self.coordinate = coordinate
        self.radius = radius
        self.monitoringMode = monitoringMode
    }
    
    init?(json : String) {
        guard let data = json.data(using: .utf8),
                let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String],
                let identifier = jsonDict?["identifier"],
                let longiture = jsonDict?["longitude"],
                let latitude = jsonDict?["latitude"],
                let radius = jsonDict?["radius"],
                let monitoringMode = jsonDict?["monitoringMode"]
            else { return nil }
        
        self.init(
                identifier: identifier,
                coordinate: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longiture) ?? 0),
                radius: Int(radius) ?? 0,
                monitoringMode: monitoringMode == "0" ? .Entering : .Exiting
            )
    }
    
    var jsonRepresentation : String {
        let jsonDict =
            [
                "identifier": identifier,
                "latitude" : String(coordinate.latitude),
                "longitude" : String(coordinate.longitude),
                "radius" : String(radius),
                "monitoringMode" : String(monitoringMode.rawValue)
            ]
        
        if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
            let jsonString = String(data:data, encoding:.utf8) {
            return jsonString
        } else { return "" }
    }
}
