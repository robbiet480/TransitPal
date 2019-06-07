//
//  ClipperData.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

public class ClipperData {
    // Epoch for Clipper is 1900-01-01 00:00:00 UTC
    static let Epoch = Date(timeIntervalSince1970: -2208988800)

    static let RecordLength = 32

    public enum ClipperAgency: Int {
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
    }

    static func getStation(_ agencyId: Int, _ stationId: Int, _ isEnd: Bool) -> Station? {
        if let stationInDB = clipperData.getStation(agencyId, stationId) {
            return stationInDB
        }

        let humanReadableID = String(format:"0x%02x", agencyId) + "/" + String(format:"0x%02x", stationId)

        if agencyId == ClipperAgency.Caltrain.rawValue || agencyId == ClipperAgency.GoldenGateTransit.rawValue {
            if stationId == 0xffff {
                return Station(nameOnly: "(End of line)")
            }
            return Station(nameOnly: "Zone #\(stationId)")
        }

        if isEnd && stationId == 0xffff {
            return nil
        }

        return Station(nameOnly: "Unknown (\(humanReadableID))")
    }
}
