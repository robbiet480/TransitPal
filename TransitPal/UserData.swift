//
//  UserData.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreNFC
import PromiseKit

final class UserData: NSObject, BindableObject, NFCTagReaderSessionDelegate {
    private(set) var willChange = PassthroughSubject<UserData, Never>()

    public var processedTag: TransitTag? {
        didSet {
            self.willChange.send(self)
        }
    }

    func startScan() {
        let readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        readerSession?.alertMessage = "Hold your iPhone near an NFC transit card."
        readerSession?.begin()
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
            session.invalidate(errorMessage: "More than 1 tag was found. Please present only 1 tag.")
            return
        }

        guard let firstTag = tags.first else {
            print("Unable to get first tag")
            session.invalidate(errorMessage: "Unable to get first tag")
            return
        }

        print("Got a tag!", firstTag)

        session.connect(to: firstTag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            print("Connected to tag!")

            var importPromise: Promise<TransitTag>?

            switch firstTag {
            case .miFare(let discoveredTag):
                print("Got a MiFare tag!", discoveredTag.identifier, discoveredTag.mifareFamily)
                importPromise = ClipperTag().importTag(discoveredTag)
            case .feliCa(let discoveredTag):
                print("Got a FeliCa tag!", discoveredTag.currentSystemCode, discoveredTag.currentIDm)
            case .iso15693(let discoveredTag):
                print("Got a ISO 15693 tag!", discoveredTag.icManufacturerCode, discoveredTag.icSerialNumber, discoveredTag.identifier)
            case .iso7816(let discoveredTag):
                print("Got a ISO 7816 tag!", discoveredTag.initialSelectedAID, discoveredTag.identifier)
            @unknown default:
                session.invalidate(errorMessage: "TransitPal doesn't support this kind of tag!")
            }

            importPromise?.done { tag in
                print("Got tag!", tag)
                self.processedTag = tag
                session.invalidate()
            }.catch { err in
                session.invalidate(errorMessage: err.localizedDescription)
            }
        }
    }
}
