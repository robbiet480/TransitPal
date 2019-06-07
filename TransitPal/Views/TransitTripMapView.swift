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
        TransitTripMapView(from: Station(), to: Station())
    }
}
#endif
