//
//  TransitEventRow.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct TransitEventRow : View {
    @EnvironmentObject var userData: UserData

    var event: TransitEvent

    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true

        var amount: String = ""
        var description: String = ""
        var icon: FontAwesome = .questionCircle
        var timestamp: String = dateFormatter.string(from: event.Timestamp)

        if let trip = event as? TransitTrip {
            amount = trip.prettyFare
            description = "\(trip.From.bestName(false)) → \(trip.To.bestName(false))"
            icon = trip.Mode.icon
            if let exitTime = trip.ExitTimestamp {
                timestamp = "\(timestamp) → \(dateFormatter.string(from: exitTime))"
            }
        } else if let refill = event as? TransitRefill {
            amount = "+ " + refill.prettyAmount
            description = "Machine ID \(refill.MachineID)"
            icon = TransportType.pos.icon
        }

        let image = UIImage.fontAwesomeIcon(name: icon, style: .solid,
                                            textColor: .label, size: CGSize(width: 30, height: 30))

        return HStack {
            Image(uiImage: image)
            VStack(alignment: .leading) {
                Text(event.Agency.name.english).font(.headline).lineLimit(1)
                Text(description).font(.callout).lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(amount).font(.callout)
                Text(timestamp).font(.callout)
            }
        }
    }
}

#if DEBUG
struct TransitEventRow_Previews : PreviewProvider {
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
        
        return List {
            TransitEventRow(event: refill)
            TransitEventRow(event: trip)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif

