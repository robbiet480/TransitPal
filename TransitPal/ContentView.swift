//
//  ContentView.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI
import CoreNFC

struct ContentView : View {
    // var readerSession: NFCTagReaderSession?
    let nfcRead = NFCReader()

    var body: some View {
        Button(action: {
            let readerSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self.nfcRead,
                                                queue: nil)
            readerSession?.alertMessage = "Hold your iPhone near an NFC transit card."
            readerSession?.begin()
        }) {
            Text("Scan for Tag")
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
