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

    @State var selectedEvent: TransitEvent? = nil
    
    @State var showEvent = false

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

    var header: Text {
        if let tag = self.userData.processedTag {
            return Text(verbatim: "Balance \(tag.prettyBalance)")
        }
        return Text(verbatim: "")
    }
    
    var body: some View {
        return List {
            self.header

            ForEach(self.eventsByDate.keys.sorted().reversed(), id: \.self) { (date: Date) in
                Section(header: Text(self.dateFormatter.string(from: date))) {
                    ForEach(self.eventsByDate[date]!) { (event: TransitEvent) in
                        Button(action: {
                            self.selectedEvent = event
                            self.showEvent = true
                        }) {
                            TransitEventRow(event: event)
                        }
                    }
                }
            }
        }
        .padding(.top) // https://stackoverflow.com/a/57243883/486182
        .sheet(isPresented: $showEvent) { TransitEventDetailView(event: self.selectedEvent!) }
        .navigationBarTitle(Text(self.userData.processedTag?.description ?? "New Tag"))
        .onAppear {
            self.userData.processedTag = nil
            self.userData.startScan()
        }
        .onDisappear {
            // BUG: onDisappear is not called?
            self.userData.processedTag = nil
        }
    }
}

#if DEBUG
struct CardEventList_Previews : PreviewProvider {
    static var previews: some View {
        let refill = ClipperRefill()
        var op = Operator()
        op.name.english = "BART"
        refill.Agency = op
        refill.Amount = 2999
        refill.MachineID = "1a2b3c4d"
        
        let trip = ClipperTrip()
        trip.Timestamp = Date(timeIntervalSinceNow: -180)
        trip.ExitTimestamp = Date()
        trip.Fare = 200
        var fromStation = Station(nameOnly: "19th St. Oakland")
        fromStation.latitude = 37.808350
        fromStation.longitude = -122.268602
        trip.From = fromStation
        
        var toStation = Station(nameOnly: "12th St. Oakland City Center")
        toStation.latitude = 37.803768
        toStation.longitude = -122.271450
        trip.To = toStation
        trip.Agency = op
        trip.Mode = .metro
        
        let userData = UserData()
        let tag = TransitTag(.miFare)
        tag.Balance = 5630
        tag.Refills = [refill]
        tag.Trips = [trip]
        tag.Serial = "12345678"
        userData.processedTag = tag
        
        return CardHistoryList().environmentObject(userData)
    }
}
#endif
