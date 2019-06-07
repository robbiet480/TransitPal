//
//  CardEventList.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI
import CoreNFC

struct CardHistoryList : View {
    @EnvironmentObject var nfcRead: NFCReader

    var eventsByDate: [Date: [TransitEvent]] {
        guard let tag = self.nfcRead.processedTag else { return [:] }
        return Dictionary(grouping: tag.Events, by: { (event: TransitEvent) -> Date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: event.Timestamp)
            return Calendar.current.date(from: components)!
        })
    }

    var body: some View {
        let clearButton = Button(action: { self.nfcRead.processedTag = nil }) { Text("Clear") }
        let scanButton = Button(action: { self.startScan() }) { Text("Scan") }

        let sortedDates = self.eventsByDate.keys.sorted().reversed().identified(by: \.self)

        var title: String = "TransitPal"

        if let tag = self.nfcRead.processedTag {
            title = tag.description
        }

        return List {
            if self.nfcRead.processedTag != nil {
                Text(verbatim: "Balance \(self.nfcRead.processedTag!.prettyBalance)")
            }

            ForEach(sortedDates) { (date: Date) in
                Section(header: Text(self.dateFormatter.string(from: date))) {
                    ForEach(self.eventsByDate[date]!) { (event: TransitEvent) in
                        TransitEventRow(event: event)
                    }
                }
            }
        }.navigationBarTitle(Text(title)).navigationBarItems(leading: clearButton, trailing: scanButton)
    }

    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func startScan() {
        let readerSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self.nfcRead)
        readerSession?.alertMessage = "Hold your iPhone near an NFC transit card."
        readerSession?.begin()
    }
}

#if DEBUG
struct CardEventList_Previews : PreviewProvider {
    static var previews: some View {
        CardHistoryList()
    }
}
#endif
