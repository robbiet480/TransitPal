//
//  MdST+Extensions.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

extension Station {
    init(nameOnly: String) {
        self.name.english = nameOnly
        self.name.englishShort = nameOnly
        self.name.local = nameOnly
        self.name.localShort = nameOnly
    }
}
