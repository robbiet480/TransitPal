//
//  ClipperTag.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import CoreNFC
import PromiseKit

class ClipperTag: TransitTag {
    init() {
        super.init(.miFare)
    }

    override var description: String {
        if let serial = self.Serial {
            return "Clipper \(serial)"
        }
        return "Clipper"
    }

    override func importTag(_ foundTag: NFCNDEFTag) -> Promise<TransitTag> {
        guard let miFareTag = foundTag as? NFCMiFareTag else {
            fatalError("Was given a mifare tag that wasn't actually mifare!!!")
        }

        return firstly {
            miFareTag.selectApplication([0x90, 0x11, 0xf2])
        }.then { Void -> Promise<[Data]> in
            let files: [UInt8] = [0x2, 0x4, 0x8, 0xe]

            var filesIterator = files.makeIterator()

            let filesGenerator = AnyIterator<Promise<Data>> {
                guard let fileID = filesIterator.next() else { return nil }
                if fileID == 0x4 {
                    return miFareTag.getRecord(fileID)
                }
                return miFareTag.getFile(fileID)
            }

            return when(fulfilled: filesGenerator, concurrently: 1)
        }.map { files in
            let balanceData = files[0]
            let refillData = files[1]
            let cardData = files[2]
            let tripsData = files[3]

            let balanceDataArr = [UInt8](balanceData)

            let balance = balanceDataArr.toInt32(18, 2)

            let trips = self.splitTrips(tripsData).sorted()

            let refills = [UInt8](refillData).chunks(32).compactMap { ClipperRefill(Data(bytes: $0, count: 32)) }.sorted()

            self.Trips = trips
            self.Refills = refills
            self.Serial = String([UInt8](cardData).toInt(1, 4))
            self.Balance = Int(balance)

            return self
        }
    }

    private func splitTrips(_ tripData: Data) -> [ClipperTrip] {
        var trips: [ClipperTrip] = []

        var pos = tripData.count - ClipperData.RecordLength

        while pos >= 0 {
            if [UInt8](tripData).toInt(pos + 0x2, 2) == 0 {
                pos -= ClipperData.RecordLength
                continue
            }

            let tripSlice = tripData[pos..<(pos + ClipperData.RecordLength)]

            guard let parsedTrip = ClipperTrip(tripSlice) else {
                print("Unable to convert trip!!!!", tripSlice.hexEncodedString())
                break
            }

            if let existingTripIdx = trips.firstIndex(where: { $0.Timestamp == parsedTrip.Timestamp }) {
                let existingTrip = trips[existingTripIdx]
                if existingTrip.ExitTimestamp != nil {
                    // Old trip has exit timestamp, and is therefore better.
                    // print("Old trip has exit timestamp, and is therefore better.")
                    pos -= ClipperData.RecordLength
                    continue
                } else {
                    // print("Removing existing trip at \(existingTripIdx)")
                    trips.remove(at: existingTripIdx)
                }
            }

            trips.append(parsedTrip)
            pos -= ClipperData.RecordLength
        }

        return trips
    }

    public static func convertDate(_ interval: TimeInterval) -> Date {
        return Date(timeInterval: interval, since: ClipperData.Epoch)
    }
}
