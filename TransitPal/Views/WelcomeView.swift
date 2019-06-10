//
//  WelcomeView.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/7/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct WelcomeView : View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        NavigationView {
            Text("Welcome to TransitPal!").font(.largeTitle)

            VStack(alignment: .center, spacing: 20) {
                NavigationButton(destination: CardHistoryList(), onTrigger: { () -> Bool in
                    self.userData.processedTag = nil
                    self.userData.startScan()
                    return true
                }) {
                    Text("Scan a tag")
                }
                HStack {
                    Button(action: {
                        print("Show supported tags!")
                    }) {
                        Text("Supported Tags")
                    }
                    Spacer(minLength: 150)
                    Button(action: {
                        print("Show history!")
                    }) {
                        Text("History")
                    }
                }
            }
            .padding()
            .navigationBarItems(trailing: Button(action: { print("Open settings!") }) { Image(systemName: "gear") })
        }
    }
}

#if DEBUG
struct WelcomeView_Previews : PreviewProvider {
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
        
        return WelcomeView().environmentObject(userData)
    }
}
#endif
