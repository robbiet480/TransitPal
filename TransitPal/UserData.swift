//
//  UserData.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreNFC

final class UserData: BindableObject {
    let didChange = PassthroughSubject<UserData, Never>()

    public var processedTag: TransitTag? {
        didSet {
            self.didChange.send(self)
        }
    }

    public var colorScheme: ColorScheme? {
        didSet {
            self.didChange.send(self)
        }
    }

    public var nfcReader: NFCReader = NFCReader()
}
