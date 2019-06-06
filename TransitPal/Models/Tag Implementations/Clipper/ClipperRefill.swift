//
//  ClipperRefill.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

class ClipperRefill: TransitRefill {
    init(_ data: Data) {
        super.init()
        self.Agency = ClipperAgency(rawValue: UInt(data.subdata(in: 0x2..<0x2+2).last!))!
        self.Timestamp = Date(timeInterval: TimeInterval(dataToInt(data, 0x4, 4)), since: Date(timeIntervalSince1970: -2208988800))

        self.MachineID = data.subdata(in: 0x8..<0x10).hexEncodedString()
        let amount: Int16 = data.subdata(in: 0xe..<0xe+2).withUnsafeBytes { $0.pointee }
        self.Amount = amount.bigEndian
    }
}
