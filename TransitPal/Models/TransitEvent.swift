//
//  TransitEvent.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftUI

class TransitEvent: CustomDebugStringConvertible, Comparable, Identifiable {
    var id = UUID()
    var Timestamp: Date = Date()
    var Agency: ClipperAgency = .Unknown

    var debugDescription: String {
        return "Timestamp: \(self.Timestamp), Agency: \(self.Agency)"
    }

    static func ==(lhs: TransitEvent, rhs: TransitEvent) -> Bool {
        return lhs.Agency == rhs.Agency && lhs.Timestamp == rhs.Timestamp
    }

    static func <(lhs: TransitEvent, rhs: TransitEvent) -> Bool {
        return lhs.Timestamp > rhs.Timestamp
    }
}
