//
//  Utils.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

typealias ByteArray = [UInt8]

extension ByteArray {
    public func toInt32(_ offset: Int, _ length: Int) -> Int32 {
        return Int32(self.toInt(offset, length))
    }

    public func toInt(_ offset: Int, _ length: Int) -> Int {
        if (self.count < offset + length) {
            fatalError("offset + length must be less than or equal to b.length")
        }
        var value = 0
        for i in 0..<length {
            let shift = (length - 1 - i) * 8
            value += (Int(self[i + offset]) & 0xFF) << shift
        }
        return value
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
