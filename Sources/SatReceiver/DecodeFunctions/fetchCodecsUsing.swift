//  -------------------------------------------------------------------
//  File: fetchCodecsUsing.swift
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

typealias PidTypeTuple = (Int, Int)
typealias PidTypeTupleArray = [PidTypeTuple]
//private var pidTypeTupleArray: PidTypeTupleArray = []


fileprivate let LM_PID_CODECS = [
    0: "-",
    2: "MP2",
    3: "MP3",
    4: "MPA",
    15: "ACC",
    16: "H263",
    27: "H264",
    32: "MPA",
    36: "H265",
    129: "AC3",
]

func fetchCodecsUsing(array: PidTypeTupleArray) -> String {
    var video = ""
    var audio = ""
    if array.count != 2 {
        logError("LongmyndMonitor.\(#function) : PidTypeTupleArray != 2")
        return strCodecs()
    }
    
    // ES info on the BATC Wiki at
    // https://en.wikipedia.org/wiki/Program-specific_information#Elementary_stream_types
    
    // What is a PMT PID?
    // The program map table (PMT) is a list of the PIDs used for each program and what they are;
    // there is one PMT for each program within a TS. The PMT also has a PID and it is always
    // the first (lowest number) PID for the program.
    
    // To enable easy decoding the following DVB PIDs are recommended: Video 256, Audio, 257, PMT 32 or 4095, PCR 256 or 258.
    // Service Name should be set to CallSign. PMT PIDs 4000 – 4010 should not be used.
    // PID should be set as:
    // Video 256
    // Audio 257
    // Audio PMT 32 or 4095
    // Audio PCR 257 or 258
    
    // CURRENTLY GETTING
    //    Beacon:
    //        fetchCodecsUsing(array:) PidTypeTupleArray (258 3), (257 27) == MP3 H264
    //        fetchCodecsUsing(array:) PidTypeTupleArray (257 27), (258 3) == H264 MP3
    //    Other:
    //        fetchCodecsUsing(array:) PidTypeTupleArray (256 27), (257 15) == H264 ACC
    //        fetchCodecsUsing(array:) PidTypeTupleArray (257 15), (256 27) == ACC H264
    
    // TODO: GET THIS WORKING PROPERLY
    
    if array[0].0 == 256 && array[1].0 == 257 {
        video = LM_PID_CODECS[array[0].1] ?? "???"
        audio = LM_PID_CODECS[array[1].1] ?? "???"
    }
    if array[0].0 == 257 && array[1].0 == 258 {
        video = LM_PID_CODECS[array[0].1] ?? "???"
        audio = LM_PID_CODECS[array[1].1] ?? "???"
    }
    //        logProgress("LongmyndMonitor.\(#function) : array: \(array)")
    return strCodecs(video, audio)
}
