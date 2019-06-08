//
//  CardEventList.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct CardHistoryList : View {
    @EnvironmentObject var userData: UserData

    @State var selectedEvent: TransitEvent?

    @Environment(\.colorScheme) var scheme

    var eventsByDate: [Date: [TransitEvent]] {
        guard let tag = self.userData.processedTag else { return [:] }
        return Dictionary(grouping: tag.Events, by: { (event: TransitEvent) -> Date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: event.Timestamp)
            return Calendar.current.date(from: components)!
        })
    }

    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        let sortedDates = self.eventsByDate.keys.sorted().reversed().identified(by: \.self)

        return List {
            if self.userData.processedTag != nil {
                Text(verbatim: "Balance \(self.userData.processedTag!.prettyBalance)")
            }

            ForEach(sortedDates) { (date: Date) in
                Section(header: Text(self.dateFormatter.string(from: date))) {
                    ForEach(self.eventsByDate[date]!) { (event: TransitEvent) in
                        // PresentationButton(TransitEventRow(event: event), destination: TransitEventDetailView(event: event))
                        Button(action: {
                            self.selectedEvent = event
                        }) {
                            TransitEventRow(event: event)
                        }
                    }
                }
            }
        }
        .presentation(self.selectedEvent != nil ? Modal(TransitEventDetailView(event: self.selectedEvent!), onDismiss: {
            self.selectedEvent = nil
        }) : nil)
        .navigationBarTitle(Text(self.userData.processedTag?.description ?? "New Tag"))
    }
}

#if DEBUG
struct CardEventList_Previews : PreviewProvider {
    static var previews: some View {
        CardHistoryList()
    }
}
#endif
