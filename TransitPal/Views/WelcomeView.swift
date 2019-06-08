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
        WelcomeView()
    }
}
#endif
