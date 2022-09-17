//  -------------------------------------------------------------------
//  File: strConstellationAndFecFrom.swift
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

fileprivate let MODCOD_DVB_S: [(constellation: String, fec: String)] = [
    ("QPSK", "1/2"), ("QPSK", "2/3"), ("QPSK", "3/4"), ("QPSK", "5/6"), ("QPSK", "7/8")
]
// TODO: what is ("DummyPL", "") all about?
fileprivate let MODCOD_DVB_S2: [(constellation: String, fec: String)] = [
    ("DummyPL", ""), ("QPSK", "1/4"), ("QPSK", "1/3"), ("QPSK", "2/5"),
    ("QPSK", "1/2"), ("QPSK", "3/5"), ("QPSK", "2/3"), ("QPSK", "3/4"),
    ("QPSK", "4/5"), ("QPSK", "5/6"), ("QPSK", "8/9"), ("QPSK", "9/10"),
    
    ("8PSK", "3/5"), ("8PSK", "2/3"), ("8PSK", "3/4"), ("8PSK", "5/6"),
    ("8PSK", "8/9"), ("8PSK", "9/10"),
    
    ("16APSK", "2/3"), ("16APSK", "3/4"), ("16APSK", "4/5"), ("16APSK", "5/6"),
    ("16APSK", "8/9"), ("16APSK", "9/10"), ("32APSK", "3/4"), ("32APSK", "4/5"),
    ("32APSK", "5/6"), ("32APSK", "8/9"), ("32APSK", "9/10")
]


func strConstellationAndFecFrom(modcod: Int, state: RxStateType) -> (constellation: String, fec: String) {
    var result = ("???", "???")
    switch state {
        case .LockedS:
            if (0..<MODCOD_DVB_S.count).contains(modcod) {
                result = MODCOD_DVB_S[modcod]
            } else {
                logError("Longmynd.\(#function) : case 18 -  invalid MODCOD: \(modcod) for \(state)")
            }
        case .LockedS2:
            if (0..<MODCOD_DVB_S2.count).contains(modcod) {
                result = MODCOD_DVB_S2[modcod]
            } else {
                logError("Longmynd.\(#function) : case 18 -  invalid MODCOD: \(modcod) for \(state)")

            }
        default:
            logError("DecodeFunctions.\(#function) : case 18 -  invalid MODCOD: \(modcod) for \(state)")
    }
    return result
}
