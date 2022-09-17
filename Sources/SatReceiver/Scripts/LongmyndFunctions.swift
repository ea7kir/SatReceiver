//  -------------------------------------------------------------------
//  File: LongmyndFunctions.swift
//
//  This file is part of the SatController 'Suite'. It's purpose is
//  to remotely control and monitor a QO-100 DATV station over a LAN.
//
//  Copyright (C) 2021 Michael Naylor EA7KIR http://michaelnaylor.es
//
//  The 'Suite' is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  The 'Suite' is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General License for more details.
//
//  You should have received a copy of the GNU General License
//  along with  SatServer.  If not, see <https://www.gnu.org/licenses/>.
//  -------------------------------------------------------------------

import Foundation

typealias LmTupleType = (lmId: Int, lmValue: String)

fileprivate var fd: Int32 = -1
fileprivate var binaryIsLoaded: Bool = false
//fileprivate var process = Process()

// MARK: Syncronous function to stop and start the longmynd binary

//func restartLongmyndBinary(with params: [String]) {
//    let SCRIPT_TO_STOP_START_LONGMYND = "/home/pirec/startLongmynd.sh"
//    let LONGMYND_DIRECTORY = "/home/pirec/longmynd"
//    let LONGMYND_STATUS_PIPE  = "/home/pirec/longmynd/longmynd_main_status"
//    binaryIsLoaded = false
//    var success = false
//
//    // MARK: Start longmyd
//
//    logProgress("LongmyndFunctions.\(#function) : with \(params)")
//
//    let process = Process()
//    logProgress("LongmyndFunctions.\(#function) : starting longmynd")
//    process.currentDirectoryURL = URL(fileURLWithPath: LONGMYND_DIRECTORY)
//    process.executableURL = URL(fileURLWithPath: SCRIPT_TO_STOP_START_LONGMYND)
//    process.arguments = params
//    process.standardInput = nil
//
//    do {
//        try process.run() // but don't wait
////        process.waitUntilExit()
//        success = true
//        logProgress("LongmyndFunctions.\(#function) : \(SCRIPT_TO_STOP_START_LONGMYND) started ok")
//    } catch {
//        logError("LongmyndFunctions.\(#function) : \(SCRIPT_TO_STOP_START_LONGMYND) failed to start")
//    }
//
//    // MARK: open FIFO - once only and and keep it open
//
//    if success && fd < 0 {
//        fd = open(LONGMYND_STATUS_PIPE, O_RDONLY)
//        if fd < 0 {
//            logError("LongmyndFunctions.\(#function) : failed to open \(LONGMYND_STATUS_PIPE)")
//            fd = -1
//        }
//    }
//    binaryIsLoaded = success && fd >= 0
//}

func restartLongmyndBinary(with params: [String]) {
    let SCRIPT_TO_STOP_START_LONGMYND = "/home/pirec/startLongmynd.sh"
    let LM_STATUS_PIPE  = "/home/pirec/longmynd/longmynd_main_status"
    binaryIsLoaded = false
    var success = false
    
    logProgress("LongmyndFunctions.\(#function) : with \(params)")
    
    let process = Process()
    logProgress("LongmyndFunctions.\(#function) : starting longmynd")
    process.executableURL = URL(fileURLWithPath: SCRIPT_TO_STOP_START_LONGMYND)
    process.arguments = params
    process.standardInput = nil
    
    do {
        try process.run() // but don't wait
        success = true
        logProgress("LongmyndFunctions.\(#function) : \(SCRIPT_TO_STOP_START_LONGMYND) started ok")
    } catch {
        logError("LongmyndFunctions.\(#function) : \(SCRIPT_TO_STOP_START_LONGMYND) failed to start")
    }
    
    // MARK: open FIFO - once only and and keep it open
    
    if success && fd < 0 {
        fd = open(LM_STATUS_PIPE, O_RDONLY)
        if fd < 0 {
            logError("LongmyndFunctions.\(#function) : failed to open \(LM_STATUS_PIPE)")
            fd = -1
        }
    }
    binaryIsLoaded = success && fd >= 0
}

// MARK: Function to read in the longmynd statue stream

func readTuple() -> LmTupleType? {
    var num: size_t = 0
    var char: CChar = CChar(0)
    var rawMessage = [CChar]()
    var strMessage = ""
    var components = [String]()
    var lmTuple = LmTupleType(0, "")
    var valid = false

    guard binaryIsLoaded == true else {
        return nil
    }
    while char != CChar(10) {
        num = read(fd, &char, 1)
        if num <= 0 {
            return nil
        }
        if char != CChar(10) {
            rawMessage.append(char)
        }
    }
    rawMessage.append(CChar(0))
    rawMessage.withUnsafeBufferPointer { ptr in
        // TODO: change the following to catch errors
        strMessage = String(cString: ptr.baseAddress!)
        // regex cheat sheet https://cheatography.com/davechild/cheat-sheets/regular-expressions/
        //        if let _ = str.range(of: #"^\$\d+,[-]*\d+$"#, options: .regularExpression) {
        if let _ = strMessage.range(of: #"^\$\d+,"#, options: .regularExpression) {
            strMessage.remove(at: strMessage.startIndex)
            components = strMessage.components(separatedBy: ",")
            lmTuple.lmId = Int(components[0])!
            lmTuple.lmValue = components[1]
            valid = true
        } else {
            logError("LongmyndFunctions.\(#function) : invalid rawMessage \(rawMessage)")
        }
    }
    return valid ? lmTuple : nil
}

// MARK: Function to kill the longmynd binary

func killLongmyndBinary() {
    let SCRIPT_TO_KILL_LONGMYND = "/home/pirec/killLongmynd.sh"
    logProgress("LongmyndFunctions.\(#function) : kill longmynd binary")
     let _ = close(fd)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: SCRIPT_TO_KILL_LONGMYND)
    process.standardInput = nil
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        logError("LongmyndFunctions.\(#function) : \(SCRIPT_TO_KILL_LONGMYND) failed with \(error.localizedDescription)")
    }
}
