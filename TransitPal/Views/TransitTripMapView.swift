//
//  TransitTripMapView.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import SwiftUI
import MapKit

struct TransitTripMapView: UIViewRepresentable {
    var from: Station
    var to: Station

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let annotations = [self.from.annotation, self.to.annotation]
        view.addAnnotations(annotations)
        view.showAnnotations(annotations, animated: false)
    }
}

#if DEBUG
struct TransitTripMapView_Previews : PreviewProvider {
    static var previews: some View {
        var fromStation = Station(nameOnly: "19th St. Oakland")
        fromStation.latitude = 37.808350
        fromStation.longitude = -122.268602
        
        var toStation = Station(nameOnly: "12th St. Oakland City Center")
        toStation.latitude = 37.803768
        toStation.longitude = -122.271450
        return TransitTripMapView(from: fromStation, to: toStation)
    }
}
#endif
