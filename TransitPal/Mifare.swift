//
//  Mifare.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/4/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import CoreNFC
import PromiseKit

public enum MiFareResponse: UInt8, LocalizedError, CaseIterable {
    case OperationOK = 0x00
    case NoChanges = 0x0C
    case OutOfEEPROMError = 0x0E
    case IllegalCommandCode = 0x1C
    case IntegrityError = 0x1E
    case NoSuchKey = 0x40
    case LengthError = 0x7E
    case PermissionDenied = 0x9D
    case ParameterError = 0x9E
    case ApplicationNotFound = 0xA0
    case ApplIntegrityError = 0xA1
    case AuthenticationError = 0xAE
    case AdditionalFrame = 0xAF
    case BoundaryError = 0xBE
    case PICCIntegrityError = 0xC1
    case CommandAborted = 0xCA
    case PICCDisabledError = 0xCD
    case CountError = 0xCE
    case DuplicateError = 0xDE
    case EEPROMError = 0xEE
    case FileNotFound = 0xF0
    case FileIntegrityError = 0xF1

    case InvalidResponse = 0x99

    var localizedDescription: String {
        switch self {
        case .OperationOK: return "OperationOK"
        case .NoChanges: return "NoChanges"
        case .OutOfEEPROMError: return "OutOfEEPROMError"
        case .IllegalCommandCode: return "IllegalCommandCode"
        case .IntegrityError: return "IntegrityError"
        case .NoSuchKey: return "NoSuchKey"
        case .LengthError: return "LengthError"
        case .PermissionDenied: return "PermissionDenied"
        case .ParameterError: return "ParameterError"
        case .ApplicationNotFound: return "ApplicationNotFound"
        case .ApplIntegrityError: return "ApplIntegrityError"
        case .AuthenticationError: return "AuthenticationError"
        case .AdditionalFrame: return "AdditionalFrame"
        case .BoundaryError: return "BoundaryError"
        case .PICCIntegrityError: return "PiccIntegrityError"
        case .CommandAborted: return "CommandAborted"
        case .PICCDisabledError: return "PiccDisabledError"
        case .CountError: return "CountError"
        case .DuplicateError: return "DuplicateError"
        case .EEPROMError: return "EepromError"
        case .FileNotFound: return "FileNotFound"
        case .FileIntegrityError: return "FileIntegrityError"
        case .InvalidResponse: return "InvalidResponse"
        }
    }
}

extension NFCMiFareTag {
    public func sendCommand(_ command: UInt8) -> Promise<Data> {
        return self.sendRequest(command, [])
    }

    public func sendRequest(_ command: UInt8, _ parameters: [UInt8]) -> Promise<Data> {
        return Promise { seal in
            func getTagData(_ cmd: UInt8, _ params: [UInt8], _ existingData: Data? = nil) {
                self.sendMiFareCommand(commandPacket: wrapCommand(cmd, params)) { (cmdResp, err) in
                    if let cmdErr = err {
                        print("Received error while sending command!", cmdErr)
                        seal.reject(cmdErr)
                        return
                    }

                    guard cmdResp[cmdResp.count - 2] == 0x91 else {
                        seal.reject(MiFareResponse.InvalidResponse)
                        return
                    }

                    guard let rawStatusFrame = cmdResp.last, let statusFrame = MiFareResponse(rawValue: rawStatusFrame) else {
                        print("Unknown status response!", cmdResp, cmdResp.hexEncodedString())
                        seal.reject(MiFareResponse.InvalidResponse)
                        return
                    }

                    var allData: Data = cmdResp[0..<cmdResp.count - 2]

                    if let existing = existingData {
                        allData.insert(contentsOf: existing, at: 0)
                    }

                    switch statusFrame {
                    case .OperationOK:
                        // print("OK status!")
                        seal.fulfill(allData)
                        return
                    case .AdditionalFrame:
                        // print("Additional frame(s)!")
                        getTagData(0xAF, [], allData)
                        return
                    default:
                        print("Received not good response", statusFrame, cmdResp.hexEncodedString(), "(command \(command) params \(parameters)")
                        seal.reject(statusFrame)
                        return
                    }
                }
            }
            getTagData(command, parameters)
        }
    }

    public func wrapCommand(_ command: UInt8, _ parameters: [UInt8]) -> Data {
        var cmdArr: [UInt8] = [0x90, command, 0x00, 0x00]

        if !parameters.isEmpty {
            cmdArr.append(UInt8(parameters.count))
            cmdArr.append(contentsOf: parameters)
        }

        cmdArr.append(0x00)

        return Data(bytes: cmdArr, count: cmdArr.count)
    }

    public func getFile(_ fileID: UInt8) -> Promise<Data> {
        return self.sendRequest(0xBD, [fileID, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }

    public func getFileSettings(_ fileID: UInt8) -> Promise<Data> {
        return self.sendRequest(0xF5, [fileID])
    }

    public func getRecord(_ recordID: UInt8) -> Promise<Data> {
        return self.sendRequest(0xBB, [recordID, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }

    public func getValue(_ fileID: UInt8) -> Promise<Data> {
        return self.sendRequest(0x6C, [fileID])
    }

    public func selectApplication(_ applicationID: [UInt8]) -> Promise<Void> {
        return self.sendRequest(0x5A, applicationID).asVoid()
    }

    public func getFiles() -> Promise<Data> {
        return self.sendCommand(0x6F)
    }
}

extension Data {

    // Convert 0 ... 9, a ... f, A ...F to their decimal value,
    // return nil for all other input characters
    fileprivate func decodeNibble(_ u: UInt16) -> UInt8? {
        switch(u) {
        case 0x30 ... 0x39:
            return UInt8(u - 0x30)
        case 0x41 ... 0x46:
            return UInt8(u - 0x41 + 10)
        case 0x61 ... 0x66:
            return UInt8(u - 0x61 + 10)
        default:
            return nil
        }
    }

    init?(fromHexEncodedString string: String) {
        var str = string
        if str.count%2 != 0 {
            // insert 0 to get even number of chars
            str.insert("0", at: str.startIndex)
        }

        let utf16 = str.utf16
        self.init(capacity: utf16.count/2)

        var i = utf16.startIndex
        while i != str.utf16.endIndex {
            guard let hi = decodeNibble(utf16[i]),
                let lo = decodeNibble(utf16[utf16.index(i, offsetBy: 1, limitedBy: utf16.endIndex)!]) else {
                    return nil
            }
            var value = hi << 4 + lo
            self.append(&value, count: 1)
            i = utf16.index(i, offsetBy: 2, limitedBy: utf16.endIndex)!
        }
    }

    struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

public extension UnsignedInteger {
    init(_ bytes: [UInt8]) {
        precondition(bytes.count <= MemoryLayout<Self>.size)

        var value: UInt64 = 0

        for byte in bytes {
            value <<= 8
            value |= UInt64(byte)
        }

        self.init(value)
    }
}
