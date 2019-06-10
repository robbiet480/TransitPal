//
//  TransitTripView.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct TransitEventDetailView : View {
    var event: TransitEvent = TransitEvent()

    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        let isTrip = (event as? TransitTrip) != nil

        return VStack(alignment: .leading, spacing: 20) {
            if isTrip {
                TransitTripMapView(from: (event as! TransitTrip).From, to: (event as! TransitTrip).To)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 400)
            }

            VStack(alignment: .leading, spacing: 20) {
                if isTrip {
                    HStack {
                        Text(verbatim: "Tagged on").bold()
                        Spacer()
                        Text(verbatim: Self.formatter.string(from: (event as! TransitTrip).Timestamp))
                    }
                    HStack {
                        Text(verbatim: "Tagged off").bold()
                        Spacer()
                        Text(verbatim: Self.formatter.string(from: (event as! TransitTrip).ExitTimestamp!))
                    }
                    HStack {
                        Text(verbatim: "From").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitTrip).From.bestName(false))
                    }
                    HStack {
                        Text(verbatim: "To").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitTrip).To.bestName(false))
                    }
                    HStack {
                        Text(verbatim: "Fare").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitTrip).prettyFare)
                    }
                    HStack {
                        Text(verbatim: "Mode").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitTrip).Mode.description)
                    }
                } else {
                    HStack {
                        Text(verbatim: "Date/Time").bold()
                        Spacer()
                        Text(verbatim: Self.formatter.string(from: (event as! TransitRefill).Timestamp))
                    }
                    HStack {
                        Text(verbatim: "Amount").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitRefill).prettyAmount)
                    }
                    HStack {
                        Text(verbatim: "Machine ID").bold()
                        Spacer()
                        Text(verbatim: (event as! TransitRefill).MachineID)
                    }
                }
                HStack {
                    Text(verbatim: "Agency").bold()
                    Spacer()
                    Text(verbatim: event.Agency.name.english)
                }
            }.padding()
        }
    }
}

#if DEBUG
struct TransitTripView_Previews : PreviewProvider {
    static var previews: some View {
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
        var op = Operator()
        op.name.english = "BART"
        trip.Agency = op
        trip.Mode = .metro
        return TransitEventDetailView(event: trip)
    }
}
#endif
