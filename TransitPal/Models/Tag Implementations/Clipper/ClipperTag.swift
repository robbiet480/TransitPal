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

            // print("Got refill data", refillData.hexEncodedString())
            // print("Got balance data", balanceData.hexEncodedString())
            // print("Got card data", cardData.hexEncodedString())

            print("Got serial", cardData.getUnsignedInteger(at: 1, length: 4))

            print("Last use timestamp", Date(timeInterval: TimeInterval(dataToInt(balanceData, 4, 4)), since: Date(timeIntervalSince1970: -2208988800)))

            let balance: Int16 = balanceData[18...19].withUnsafeBytes { $0.pointee }
            print("Got balance $\(Double(balance.bigEndian)/100)")

            let trips = [UInt8](tripsData).chunks(32).map { ClipperTrip(Data(bytes: $0, count: 32)) }.sorted()
            print("Got trips!", trips)

            let refills = [UInt8](refillData).chunks(32).map { ClipperRefill(Data(bytes: $0, count: 32)) }.sorted()
            print("Got refills!", refills)

            let tTag = TransitTag()

            tTag.Trips = trips
            tTag.Refills = refills
            tTag.Serial = cardData.getUnsignedInteger(at: 1, length: 4).description
            tTag.Balance = Int(balance.bigEndian)

            return tTag
        }
    }
}
