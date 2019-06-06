//
//  ClipperData.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

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
        case .ACTransit: return "AC Transit"
        case .CountyConnection: return "County Connection"
        case .SamTrans: return "SamTrans"
        case .VTA: return "VTA"
        case .Caltrain_8Ride: return "Caltrain_8Ride"
        case .BART: return "BART"
        case .Caltrain: return "Caltrain"
        case .BayFerry: return "San Francisco Bay Ferry"
        case .GoldenGateFerry: return "Golden Gate Ferry"
        case .GoldenGateTransit: return "Golden Gate Transit"
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
    case Other

    var description: String {
        switch self {
        case .Ferry: return "Ferry"
        case .Train: return "Train"
        case .Tram: return "Tram"
        case .Metro: return "Metro"
        case .Bus: return "Bus"
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
