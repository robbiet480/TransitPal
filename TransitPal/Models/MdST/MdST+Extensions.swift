//
//  MdST+Extensions.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import MapKit

extension Station {
    init(nameOnly: String) {
        self.name.english = nameOnly
        self.name.englishShort = nameOnly
        self.name.local = nameOnly
        self.name.localShort = nameOnly
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
    }

    var annotation: MKAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = self.coordinate
        pin.title = self.name.english
        return pin
    }
}
