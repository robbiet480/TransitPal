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
            description = "\(trip.From.name.english) → \(trip.To.name.english)"
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
                Text(verbatim: event.Agency.name.englishShort).font(.headline)
                Text(description).lineLimit(nil).font(.callout)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(amount)
                Text(timestamp).font(.callout)
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

