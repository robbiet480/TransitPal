//
//  ClipperTrip.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftUI

class ClipperTrip: TransitTrip {
    var Route: Int16 = 0
    var VehicleNumber: Int16 = 0
    var TransportCode: TransportType = TransportType()

    override init() {}

    init?(_ data: Data) {
        super.init()

        self.Timestamp = Date(timeInterval: TimeInterval(dataToInt(data, 12, 4)), since: Date(timeIntervalSince1970: -2208988800))
        self.ExitTimestamp = Date(timeInterval: TimeInterval(dataToInt(data, 16, 4)), since: Date(timeIntervalSince1970: -2208988800))

        if self.ExitTimestamp == Date(timeIntervalSince1970: -2208988800) {
            self.ExitTimestamp = nil
        }

        let fare: Int16 = data[6...8].withUnsafeBytes { $0.pointee }
        self.Fare = fare.bigEndian

        let agency = clipperData.Metadata.operators.first { $0.key == UInt(data[2...3].last!) }

        guard let op = agency?.value else { return nil }

        self.Agency = op

        /* if let fromStation = clipperData.Stations.first(where: { $0.id == data[20...21].uint32.bigEndian / 2 }) {
            print("Got from station", fromStation)
            self.From = fromStation
        } else {
            print("NO FROM STATION", self)
        }

        if let toStation = clipperData.Stations.first(where: { $0.id == data[22...23].uint32.bigEndian / 2 }) {
            print("Got to station", toStation)
            self.To = toStation
        } else {
            print("NO TO STATION", self)
        } */

        let route: Int16 = data[28...29].withUnsafeBytes { $0.pointee }
        self.Route = route.bigEndian
        let vehicleID: Int16 = data[10...11].withUnsafeBytes { $0.pointee }
        self.VehicleNumber = vehicleID.bigEndian

        self.TransportCode = op.defaultTransport
    }

    override var debugDescription: String {
        return "Timestamp: \(self.Timestamp), ExitTimestamp: \(self.ExitTimestamp), Fare: \(self.Fare), Agency: \(self.Agency), From: \(self.From), To: \(self.To), Route: \(self.Route), VehicleNumber: \(self.VehicleNumber), TransportCode: \(self.TransportCode)"
    }

    static func ==(lhs: ClipperTrip, rhs: ClipperTrip) -> Bool {
        return lhs.From == rhs.From && lhs.To == rhs.To && lhs.Agency == rhs.Agency
    }
}
