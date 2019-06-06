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

    init?(_ filename: String) {
        guard let stationsPath = Bundle.main.url(forResource: filename, withExtension: "mdst"),
            let stationsData = try? Data(contentsOf: stationsPath) else {
                return nil
        }

        let magic = [UInt8](stationsData.subdata(in: 0..<4))

        if magic != [0x4d, 0x64, 0x53, 0x54] {
            print("Magic is invalid! \(magic)")
            return nil
        }

        let version = UInt32(bigEndian: [UInt8](stationsData[4..<8]).withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
        }.pointee)

        if version != 1 {
            print("Expected verion 1, got version \(version)")
            return nil
        }

        let stationsLength = UInt32(bigEndian: [UInt8](stationsData[8..<12]).withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
        }.pointee)

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
}
