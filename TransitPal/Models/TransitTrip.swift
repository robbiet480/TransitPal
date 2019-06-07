//
//  TransitTrip.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

class TransitTrip: TransitEvent {
    var ExitTimestamp: Date?
    var Fare: Int = 0
    var From: Station = Station()
    var To: Station = Station()

    override var debugDescription: String {
        return "Timestamp: \(self.Timestamp), ExitTimestamp: \(self.ExitTimestamp), Fare: \(self.Fare), Agency: \(self.Agency), From: \(self.From), To: \(self.To)"
    }

    static func ==(lhs: TransitTrip, rhs: TransitTrip) -> Bool {
        return lhs.From == rhs.From && lhs.To == rhs.To && lhs.Agency == rhs.Agency
    }

    var prettyFare: String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter.string(from: (NSNumber(value: Double(self.Fare)/100))) ?? "0"
    }
}
