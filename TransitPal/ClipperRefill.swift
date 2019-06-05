//
//  ClipperRefill.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

class ClipperRefill: ClipperEvent {
    var MachineID: String = ""
    var Amount: Int16 = 0

    init(_ data: Data) {
        super.init()
        self.Agency = ClipperAgency(rawValue: UInt(data.subdata(in: 0x2..<0x2+2).last!))!
        self.Timestamp = Date(timeInterval: TimeInterval(dataToInt(data, 0x4, 4)), since: Date(timeIntervalSince1970: -2208988800))

        self.MachineID = data.subdata(in: 0x8..<0x10).hexEncodedString()
        let amount: Int16 = data.subdata(in: 0xe..<0xe+2).withUnsafeBytes { $0.pointee }
        self.Amount = amount.bigEndian
    }

    override var debugDescription: String {
        return "Agency: \(self.Agency), Timestamp: \(self.Timestamp), MachineID: \(self.MachineID), Amount: \(self.Amount)"
    }

    static func ==(lhs: ClipperRefill, rhs: ClipperRefill) -> Bool {
        return lhs.MachineID == rhs.MachineID && lhs.Amount == rhs.Amount && lhs.Agency == rhs.Agency && lhs.Timestamp == rhs.Timestamp
    }
}
