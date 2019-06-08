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

    func bestName(_ short: Bool) -> String {
        let englishFull = self.name.english
        let englishShort = self.name.englishShort
        var english: String?
        let hasEnglishFull = !englishFull.isEmpty
        let hasEnglishShort = !englishShort.isEmpty

        if (hasEnglishFull && !hasEnglishShort) {
            english = englishFull
        } else if (!hasEnglishFull && hasEnglishShort) {
            english = englishShort
        } else if short {
            english = englishShort
        } else {
            english = englishFull
        }
        let localFull = name.local
        let localShort = name.localShort
        let local: String?
        let hasLocalFull = !localFull.isEmpty
        let hasLocalShort = !localShort.isEmpty

        if (hasLocalFull && !hasLocalShort) {
            local = localFull
        } else if (!hasLocalFull && hasLocalShort) {
            local = localShort
        } else if short {
            local = localShort
        } else {
            local = localFull
        }

        if let english = english, !english.isEmpty, let currentCode = Locale.current.languageCode, currentCode.hasPrefix("en") {
            return english
        }

        if let local = local, !local.isEmpty {
            // Local preferred, or English not available
            return local
        }
        // Local unavailable, use English
        return english!
    }
}

