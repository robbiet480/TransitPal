//
//  MdST.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import SwiftProtobuf

public struct MdST {
    public var Filename: String
    public var Metadata: StationDb
    public var Index: StationIndex
    public var Raw: Data
    public var Version: Int
    public var StationsStart: Int
    public var StationsEnd: Int
    public var StationsLength: Int

    static var Databases: [String: MdST] = [:]

    static var Stations: [String: [Int: Station]] = [:]

    static private let Magic: ByteArray = [0x4d, 0x64, 0x53, 0x54]

    public enum MdSTError: Error {
        case fileReadError
        case invalidMagic
        case invalidVersion
        case stationDbReadError
        case stationIndexReadError
        case stationReadError
    }

    private init() {
        self.Filename = ""
        self.Metadata = StationDb()
        self.Index = StationIndex()
        self.Raw = Data()
        self.Version = 0
        self.StationsStart = 0
        self.StationsEnd = 0
        self.StationsLength = 0
    }

    init?(_ filename: String) {
        if let existingDB = MdST.Databases[filename] {
            self = existingDB
            return
        }

        do {
            self = try MdST.load(filename)
        } catch {
            print("Error when loading MdST!", error)
            return nil
        }
    }

    static func load(_ filename: String) throws -> MdST {
        if let existingDB = MdST.Databases[filename] {
            return existingDB
        }

        print("MdST file \(filename) is being read")

        guard let dbPath = Bundle.main.url(forResource: filename, withExtension: "mdst"),
            let dbData = try? Data(contentsOf: dbPath) else {
                throw MdSTError.fileReadError
        }

        var newDB = MdST()

        newDB.Filename = filename

        newDB.Raw = dbData

        let dbDataArr = ByteArray(dbData)

        if ByteArray(dbDataArr[0..<4]) != MdST.Magic {
            print("Magic is invalid! \(dbDataArr[0..<4]))")
            throw MdSTError.invalidMagic
        }

        let version = dbDataArr.toInt32(4, 4)

        if version != 1 {
            print("Expected verion 1, got version \(version)")
            throw MdSTError.invalidVersion
        }

        newDB.Version = Int(version)

        let stationsLength = dbDataArr.toInt32(8, 4)

        newDB.StationsLength = Int(stationsLength)

        let stationDbStream = InputStream(data: dbData[12..<stationsLength])
        stationDbStream.open()

        guard let metadata = try? BinaryDelimited.parse(messageType: StationDb.self, from: stationDbStream) else {
            throw MdSTError.stationDbReadError
        }
        newDB.Metadata = metadata

        stationDbStream.close()

        guard let stationDBLength = try? newDB.Metadata.serializedData().count else {
            throw MdSTError.stationDbReadError
        }

        newDB.StationsStart = (stationDBLength + 14)

        newDB.StationsEnd = newDB.StationsStart + Int(stationsLength)

        let stationIdxStream = InputStream(data: dbData[newDB.StationsEnd..<dbData.count])
        stationIdxStream.open()

        guard let idx = try? BinaryDelimited.parse(messageType: StationIndex.self, from: stationIdxStream) else {
            throw MdSTError.stationIndexReadError
        }

        newDB.Index = idx

        stationIdxStream.close()

        MdST.Databases[filename] = newDB

        return newDB
    }

    static func buildStationID(_ agencyID: Int, _ stationID: Int) -> Int {
        return (agencyID << 16 | stationID)
    }

    func getStation(_ agencyID: Int, _ stationID: Int) -> Station? {
        let builtStationID = MdST.buildStationID(agencyID, stationID)
        
        if MdST.Stations[self.Filename] == nil { MdST.Stations[self.Filename] = [:] }

        if let existingStation = MdST.Stations[self.Filename]?[builtStationID] { return existingStation }

        guard let stationOffset = self.Index.stationMap.first(where: { $0.key == builtStationID })?.value else { return nil }

        print("Station \(builtStationID.hexString) is being retrieved from MdST")

        let stationPosition = self.StationsStart + Int(stationOffset)

        let stationsStream = InputStream(data: self.Raw[stationPosition...])
        stationsStream.open()

        var station: Station?

        do {
            station = try BinaryDelimited.parse(messageType: Station.self, from: stationsStream)
        } catch {
            print("Got error while trying to read station!", error)
        }

        stationsStream.close()

        if let foundStation = station {
            MdST.Stations[self.Filename]![builtStationID] = foundStation
            return foundStation
        }

        return nil
    }

    func getOperator(_ agencyID: Int) -> Operator? {
        return self.Metadata.operators[UInt32(agencyID)]
    }
}
