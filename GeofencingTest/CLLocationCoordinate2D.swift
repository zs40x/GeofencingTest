//
//  CLLocationCoordinate2D.swift
//  GeofencingTest
//
//  Created by Stefan Mehnert on 11/01/2017.
//  Copyright © 2017 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable { }

public func ==(rhs: CLLocationCoordinate2D, lhs: CLLocationCoordinate2D) -> Bool {
    
    guard rhs.longitude == lhs.longitude && rhs.latitude == lhs.latitude else { return false }
    
    return true
}
