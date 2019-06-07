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
    var Route: Int = 0
    var VehicleNumber: Int = 0
    var TransportCode: TransportType = TransportType()

    override init() {}

    init?(_ data: Data) {
        super.init()

        let dataArr = [UInt8](data)

        self.Timestamp = ClipperTag.convertDate(TimeInterval(dataArr.toInt(0xc, 4)))
        self.ExitTimestamp = ClipperTag.convertDate(TimeInterval(dataArr.toInt(0x10, 4)))

        if self.ExitTimestamp == Date(timeIntervalSince1970: -2208988800) {
            self.ExitTimestamp = nil
        }

        self.Fare = Int(dataArr.toInt(0x6, 2))

        let agencyID = dataArr.toInt(0x2, 2)
        let agency = clipperData.Metadata.operators.first { $0.key == agencyID }

        guard let op = agency?.value else { return nil }

        self.Agency = op

        let fromStationID = Int(dataArr.toInt(0x14, 2))

        let toStationID = Int(dataArr.toInt(0x16, 2))

        if let fromStation = clipperData.getStation(Int(agencyID), fromStationID) {
            self.From = fromStation
        } else {
            print("Cant get from station \(fromStationID)");
        }

        if let toStation = clipperData.getStation(Int(agencyID), toStationID) {
            self.To = toStation
        } else {
            print("Cant get to station \(toStationID)");
        }

        self.Route = Int(dataArr.toInt(0x1c, 2))
        self.VehicleNumber = Int(dataArr.toInt(0xa, 2))

        self.TransportCode = TransportType(dataArr.toInt(0x1e, 2), self.Agency)
    }

    override var debugDescription: String {
        return "Timestamp: \(self.Timestamp), ExitTimestamp: \(self.ExitTimestamp), Fare: \(self.Fare), Agency: \(self.Agency.name.english), From: \(self.From.name.english), To: \(self.To.name.english), Route: \(self.Route), VehicleNumber: \(self.VehicleNumber), TransportCode: \(self.TransportCode)"
    }

    static func ==(lhs: ClipperTrip, rhs: ClipperTrip) -> Bool {
        return lhs.From == rhs.From && lhs.To == rhs.To && lhs.Agency == rhs.Agency
    }
}

fileprivate extension TransportType {
    init(_ code: Int, _ agency: Operator) {
        // FIXME: Lookup Clipper operator to fix this logic.
        /*if code == 0x62 {
            if agency == .BayFerry || agency == .GoldenGateFerry {
                self = .ferry
            } else if agency == .Caltrain {
                self = .train
            } else {
                self = .tram
            }
        } else*/ if code == 0x6f {
            self = .metro
        } else if code == 0x61 || code == 0x75 {
            self = .bus
        } else {
            self = .other
        }

        self = agency.defaultTransport
    }
}
