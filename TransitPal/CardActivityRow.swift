//
//  CardActivityRow.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/5/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI

struct CardActivityRow : View {
    var event: ClipperTrip

    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        let timestamp = dateFormatter.string(from: event.Timestamp)
        var exitTimestamp = ""
        if let exit = event.ExitTimestamp, exit != event.Timestamp {
            exitTimestamp = dateFormatter.string(from: exit)
        }

        return VStack(alignment: .leading, spacing: nil) {
            HStack {
                Text(timestamp)
                Text(exitTimestamp)
            }
            HStack {
                Text(event.prettyFare)
                Text(event.prettyLine2)
            }
            HStack {
                Text(event.From.description)
                Text(event.To.description)
            }
        }
    }
}

#if DEBUG
struct CardActivityRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            CardActivityRow(event: ClipperTrip())
            CardActivityRow(event: ClipperTrip())
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif
