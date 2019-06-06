//
//  TransitRefill.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

class TransitRefill: TransitEvent {
    var MachineID: String = ""
    var Amount: Int16 = 0

    override var debugDescription: String {
        return "Agency: \(self.Agency), Timestamp: \(self.Timestamp), MachineID: \(self.MachineID), Amount: \(self.Amount)"
    }

    static func ==(lhs: TransitRefill, rhs: TransitRefill) -> Bool {
        return lhs.MachineID == rhs.MachineID && lhs.Amount == rhs.Amount && lhs.Agency == rhs.Agency && lhs.Timestamp == rhs.Timestamp
    }

    var prettyAmount: String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter.string(from: (NSNumber(value: Double(self.Amount)/100))) ?? "0"
    }
}
