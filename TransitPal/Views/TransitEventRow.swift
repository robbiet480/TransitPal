//
//  TransitEventRow.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct TransitEventRow : View {
    var event: TransitEvent

    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true

        var amount: String = ""
        var description: String = ""
        var iconName = "dollarsign.circle"
        var timestamp: String = dateFormatter.string(from: event.Timestamp)

        if let trip = event as? TransitTrip {
            amount = trip.prettyFare
            description = "\(trip.From.name.english) -> \(trip.To.name.english)"
            iconName = "arrow.left.and.right.square"
            if let exitTime = trip.ExitTimestamp {
                timestamp = "\(timestamp) -> \(dateFormatter.string(from: exitTime))"
            }
        } else if let refill = event as? TransitRefill {
            amount = refill.prettyAmount
            description = "Machine ID \(refill.MachineID)"
        }

        return HStack {
            Image(systemName: iconName)
            VStack(alignment: .leading) {
                Text(verbatim: event.Agency.name.englishShort).font(.headline)
                Text(description)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(amount)
                Text(timestamp)
            }
        }
    }
}

#if DEBUG
struct TransitEventRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            TransitEventRow(event: TransitRefill())
            TransitEventRow(event: TransitTrip())
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif

