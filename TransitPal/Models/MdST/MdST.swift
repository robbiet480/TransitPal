//
//  MdST.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftProtobuf

public class MdST {
    public var Metadata: StationDb = StationDb()
    public var Stations: [Station] = []
    public var Index: StationIndex = StationIndex()
    public var Raw: Data = Data()
    public var Magic: [UInt8] = []
    public var Version: Int = 0
    public var StationsLength: Int = 0

    init?(_ filename: String) {
        guard let stationsPath = Bundle.main.url(forResource: filename, withExtension: "mdst"),
            let stationsData = try? Data(contentsOf: stationsPath) else {
                return nil
        }

        self.Raw = stationsData

        let stationsDataArr = [UInt8](stationsData)

        let magic = Array(stationsDataArr[0..<4])

        if magic != [0x4d, 0x64, 0x53, 0x54] {
            print("Magic is invalid! \(magic)")
            return nil
        }

        self.Magic = magic

        let version = stationsDataArr.toInt32(4, 4)

        if version != 1 {
            print("Expected verion 1, got version \(version)")
            return nil
        }

        self.Version = Int(version)

        let stationsLength = stationsDataArr.toInt32(8, 4)

        self.StationsLength = Int(stationsLength)

        let stationDbStream = InputStream(data: stationsData[12..<stationsLength])
        stationDbStream.open()

        guard let metadata = try? BinaryDelimited.parse(messageType: StationDb.self, from: stationDbStream) else { return nil }
        self.Metadata = metadata

        stationDbStream.close()

        guard let stationDBLength = try? self.Metadata.serializedData().count else { return nil }

        let stationsStart = (stationDBLength + 14)

        let stationsEnd = stationsStart + Int(stationsLength)

        let stationsStream = InputStream(data: stationsData[stationsStart..<stationsEnd])
        stationsStream.open()

        while let station = try? BinaryDelimited.parse(messageType: Station.self, from: stationsStream) {
            self.Stations.append(station)
        }

        stationsStream.close()

        let stationIdxStream = InputStream(data: stationsData[stationsEnd..<stationsData.count])
        stationIdxStream.open()

        guard let idx = try? BinaryDelimited.parse(messageType: StationIndex.self, from: stationIdxStream) else { return nil }

        self.Index = idx

        stationIdxStream.close()

        return
    }

    func getStation(_ agencyID: Int, _ stationID: Int) -> Station? {
        return self.Stations.first { $0.id == (agencyID << 16 | stationID) }
    }

    func getOperator(_ agencyID: Int) -> Operator? {
        return self.Metadata.operators[UInt32(agencyID)]
    }
}
