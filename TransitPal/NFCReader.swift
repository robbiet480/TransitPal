//
//  NFCReader.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import CoreNFC
import PromiseKit
import SwiftUI
import Combine

class NFCReader: NSObject, BindableObject, NFCTagReaderSessionDelegate {
    let didChange = PassthroughSubject<NFCReader, Never>()

    public var events: [ClipperTrip] = [] {
        didSet {
            self.didChange.send(self)
        }
    }

    // MARK: - NFCTagReaderSessionDelegate
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // If necessary, you may perform additional operations on session start.
        // At this point RF polling is enabled.
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note session is no longer valid.
        // You must create a new session to restart RF polling.
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            print("More than 1 tag was found. Please present only 1 tag.")
            return
        }

        guard let firstTag = tags.first, case let .miFare(tag) = firstTag else {
            print("Unable to get first tag")
            return
        }

        print("Got mifare tag!", tag.identifier, tag.mifareFamily, tag.historicalBytes)

        session.connect(to: firstTag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            print("Got connected tag as mifare", tag, tag.identifier, tag.mifareFamily, tag.historicalBytes)

            firstly {
                tag.selectApplication([0x90, 0x11, 0xf2])
            }.then { Void -> Promise<[Data]> in
                // tag.getFile(0x04) dont work??? auth???

                let files: [UInt8] = [0x2, 0x4, 0x8, 0xe]

                var filesIterator = files.makeIterator()

                let filesGenerator = AnyIterator<Promise<Data>> {
                    guard let fileID = filesIterator.next() else { return nil }
                    if fileID == 0x4 {
                        return tag.getRecord(fileID)
                    }
                    return tag.getFile(fileID)
                }

                return when(fulfilled: filesGenerator, concurrently: 1)
            }.done { files in
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

                self.events = trips

                session.invalidate()
            }.catch { err in
                print("Received error!", err)
                if let mErr = err as? MiFareResponse {
                    session.invalidate(errorMessage: mErr.localizedDescription)
                    return
                }
                session.invalidate(errorMessage: err.localizedDescription)
            }
        }
    }
}
