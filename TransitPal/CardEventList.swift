//
//  CardEventList.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI
import CoreNFC

struct CardEventList : View {
    @EnvironmentObject var nfcRead: NFCReader

    var body: some View {

        let readerSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092],
                                                delegate: self.nfcRead, queue: nil)
        readerSession?.alertMessage = "Hold your iPhone near an NFC transit card."
        readerSession?.begin()

        return List(self.nfcRead.events.identified(by: \.id)) { event in
            CardActivityRow(event: event)
        }.navigationBarTitle(Text("Clipper"))
    }
}

#if DEBUG
struct CardEventList_Previews : PreviewProvider {
    static var previews: some View {
        CardEventList()
    }
}
#endif
