//
//  Utils.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation

func dataToLong(_ bytes: Data, _ offset: Int, _ length: Int) -> UInt64 {
    if (bytes.count < offset + length) {
        // print("offset + length must be less than or equal to b.length")
        return 0
    }

//    var value: UInt8 = 0
//    for (idx, _) in bytes.enumerated() {
//        let shift = (length - 1 - idx) * 8
//        print("Getting bytes at", idx + offset, "max length", bytes.count, "shift", shift)
//        value += (bytes[idx + offset] & 0x000000FF) << shift
//    }
//
//    print("Returning val", value)
//    return value

    return [UInt8](bytes)[offset..<offset+length].withUnsafeBytes {
        $0.bindMemory(to: UInt64.self).baseAddress!.pointee
    }.bigEndian
}

func dataToInt(_ bytes: Data, _ offset: Int, _ length: Int) -> UInt32 {
    if (bytes.count < offset + length) {
        // print("offset + length must be less than or equal to b.length")
        return 0
    }

    //    var value: UInt8 = 0
    //    for (idx, _) in bytes.enumerated() {
    //        let shift = (length - 1 - idx) * 8
    //        print("Getting bytes at", idx + offset, "max length", bytes.count, "shift", shift)
    //        value += (bytes[idx + offset] & 0x000000FF) << shift
    //    }
    //
    //    print("Returning val", value)
    //    return value

    return [UInt8](bytes)[offset..<offset+length].withUnsafeBytes {
        $0.bindMemory(to: UInt32.self).baseAddress!.pointee
    }.bigEndian
}

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Data {

    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }

    var uint16: UInt16 {
        get {
            let i16array = self.withUnsafeBytes {
                UnsafeBufferPointer<UInt16>(start: $0, count: self.count/2).map(UInt16.init(littleEndian:))
            }
            return i16array[0]
        }
    }

    var uint32: UInt32 {
        get {
            let i32array = self.withUnsafeBytes {
                UnsafeBufferPointer<UInt32>(start: $0, count: self.count/2).map(UInt32.init(littleEndian:))
            }
            return i32array[0]
        }
    }

    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
        }
    }
    var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }

    var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }

}

extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }

    var byteArrayLittleEndian: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}
