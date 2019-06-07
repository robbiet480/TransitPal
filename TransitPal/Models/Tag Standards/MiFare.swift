//
//  MiFare.swift
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

extension NFCMiFareFamily: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "Unknown/ISO14443 Type A"
        case .ultralight: return "Ultralight"
        case .plus: return "Plus"
        case .desfire: return "DESFire"
        @unknown default: return "Unknown"
        }
    }
}
