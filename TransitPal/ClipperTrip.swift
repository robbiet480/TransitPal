//
//  ClipperTrip.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftUI

public enum ClipperAgency: UInt, CaseIterable {
    case ACTransit = 0x01
    case CountyConnection = 0x08
    case SamTrans = 0x0f
    case VTA = 0x11
    case Caltrain_8Ride = 0x173
    case BART = 0x04
    case Caltrain = 0x06
    case BayFerry = 0x1b
    case GoldenGateFerry = 0x19
    case GoldenGateTransit = 0x0b
    case MUNI = 0x12
    case Unknown = 0x00

    var description: String {
        switch self {
        case .ACTransit: return "ACTransit"
        case .CountyConnection: return "CountyConnection"
        case .SamTrans: return "SamTrans"
        case .VTA: return "VTA"
        case .Caltrain_8Ride: return "Caltrain_8Ride"
        case .BART: return "BART"
        case .Caltrain: return "Caltrain"
        case .BayFerry: return "BayFerry"
        case .GoldenGateFerry: return "GoldenGateFerry"
        case .GoldenGateTransit: return "GoldenGateTransit"
        case .MUNI: return "MUNI"
        case .Unknown: return "Unknown"
        }
    }
}

public enum ClipperStation: UInt, CaseIterable {
    case SanFranciscoFerryBuilding = 0x1b0008
}

public enum ClipperTransportCode: String, CaseIterable {
    case Ferry
    case Train
    case Tram
    case Metro
    case Bus
    case BusAlternate
    case Other

    var description: String {
        switch self {
        case .Ferry: return "Ferry"
        case .Train: return "Train"
        case .Tram: return "Tram"
        case .Metro: return "Metro"
        case .Bus: return "Bus"
        case .BusAlternate: return "BusAlternate"
        case .Other: return "Other"
        }
    }

    init(_ code: UInt8, _ agency: ClipperAgency) {
        if code == 0x62 {
            if agency == .BayFerry || agency == .GoldenGateFerry {
                self = .Ferry
            } else if agency == .Caltrain {
                self = .Train
            } else {
                self = .Tram
            }
        } else if code == 0x6f {
            self = .Metro
        } else if code == 0x61 || code == 0x75 {
            self = .Bus
        } else {
            self = .Other
        }
    }
}

class ClipperTrip: ClipperEvent {
    var ExitTimestamp: Date?
    var Fare: Int16 = 0
    var From: Int16 = 0
    var To: Int16 = 0
    var Route: Int16 = 0
    var VehicleNumber: Int16 = 0
    var TransportCode: ClipperTransportCode = .Other

    override init() {}

    init(_ data: Data) {
        super.init()

        self.Timestamp = Date(timeInterval: TimeInterval(dataToInt(data, 0xc, 4)), since: Date(timeIntervalSince1970: -2208988800))
        self.ExitTimestamp = Date(timeInterval: TimeInterval(dataToInt(data, 0x10, 4)), since: Date(timeIntervalSince1970: -2208988800))

        if self.ExitTimestamp == Date(timeIntervalSince1970: -2208988800) {
            self.ExitTimestamp = nil
        }

        let fare: Int16 = data[0x6...0x8].withUnsafeBytes { $0.pointee }
        self.Fare = fare.bigEndian

        self.Agency = ClipperAgency(rawValue: UInt(data.subdata(in: 0x2..<0x2+2).last!))!

        let fromStation: Int16 = data[0x14...0x15].withUnsafeBytes { $0.pointee }
        self.From = fromStation.bigEndian

        let toStation: Int16 = data[0x16...0x17].withUnsafeBytes { $0.pointee }

        self.To = toStation.bigEndian
        let route: Int16 = data[0x1c...0x1d].withUnsafeBytes { $0.pointee }
        self.Route = route.bigEndian
        let vehicleID: Int16 = data[0xa...0xb].withUnsafeBytes { $0.pointee }
        self.VehicleNumber = vehicleID.bigEndian

        self.TransportCode = ClipperTransportCode(data.subdata(in: 0x1e..<0x1e+2).last!, self.Agency)
    }

    var prettyFare: String {
        return "$" + (Double(self.Fare)/100).description
    }

    var prettyLine2: String {
        return "\(self.Agency.description) (\(self.TransportCode.description))"
    }

    override var debugDescription: String {
        return "Timestamp: \(self.Timestamp), ExitTimestamp: \(self.ExitTimestamp), Fare: \(self.Fare), Agency: \(self.Agency), From: \(self.From), To: \(self.To), Route: \(self.Route), VehicleNumber: \(self.VehicleNumber), TransportCode: \(self.TransportCode)"
    }

    static func ==(lhs: ClipperTrip, rhs: ClipperTrip) -> Bool {
        return lhs.From == rhs.From && lhs.To == rhs.To && lhs.Agency == rhs.Agency
    }
}
