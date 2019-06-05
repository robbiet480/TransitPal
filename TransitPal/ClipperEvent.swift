//
//  ClipperEvent.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftUI

class ClipperEvent: CustomDebugStringConvertible, Comparable, Identifiable {
    var Timestamp: Date = Date()
    var Agency: ClipperAgency = .Unknown

    var debugDescription: String {
        return "Timestamp: \(self.Timestamp), Agency: \(self.Agency)"
    }

    static func ==(lhs: ClipperEvent, rhs: ClipperEvent) -> Bool {
        return lhs.Agency == rhs.Agency && lhs.Timestamp == rhs.Timestamp
    }

    static func <(lhs: ClipperEvent, rhs: ClipperEvent) -> Bool {
        return lhs.Timestamp > rhs.Timestamp
    }

    var id: String {
        return "\(self.Timestamp)-\(self.Agency)"
    }
}
