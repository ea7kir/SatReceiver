//  -------------------------------------------------------------------
//  File: computeMarging.swift
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

fileprivate let LM_MOD_THRESHOLD: [String: Double] = [
    "DVB-S 1/2":          1.7,
    "DVB-S 2/3":          3.3,
    "DVB-S 3/4":          4.2,
    "DVB-S 5/6":          5.1,
    "DVB-S 6/7":          5.5,
    "DVB-S 7/8":          5.8,
    "DVB-S2 QPSK 1/4":   -2.3,
    "DVB-S2 QPSK 1/3":   -1.2,
    "DVB-S2 QPSK 2/5":   -0.3,
    "DVB-S2 QPSK 1/2":    1.0,
    "DVB-S2 QPSK 3/5":    2.3,
    "DVB-S2 QPSK 2/3":    3.1,
    "DVB-S2 QPSK 3/4":    4.1,
    "DVB-S2 QPSK 4/5":    4.7,
    "DVB-S2 QPSK 5/6":    5.2,
    "DVB-S2 QPSK 8/9":    6.2,
    "DVB-S2 QPSK 9/10":   6.5,
    "DVB-S2 8PSK 3/5":    5.5,
    "DVB-S2 8PSK 2/3":    6.6,
    "DVB-S2 8PSK 3/4":    7.9,
    "DVB-S2 8PSK 5/6":    9.4,
    "DVB-S2 8PSK 8/9":    10.7,
    "DVB-S2 8PSK 9/10":   11.0,
    "DVB-S2 16APSK 2/3":  9.0,
    "DVB-S2 16APSK 3/4":  10.2,
    "DVB-S2 16APSK 4/5":  11.0,
    "DVB-S2 16APSK 5/6":  11.6,
    "DVB-S2 16APSK 8/9":  12.9,
    "DVB-S2 16APSK 9/10": 13.2,
    "DVB-S2 32APSK 3/4":  12.8,
    "DVB-S2 32APSK 4/5":  13.7,
    "DVB-S2 32APSK 5/6":  14.3,
    "DVB-S2 32APSK 8/9":  15.7,
    "DVB-S2 32APSK 9/10": 16.1,
]

func computedMargin(state: RxStateType, mer: String, fec: String, constellation: String) -> String {
    if mer == strMer() || fec == strFec() {
        return strMargin()
    }
    var key = ""
    switch state {
        case .LockedS:
            key = "DVB-S \(fec)"
        case .LockedS2:
            if constellation == strConstellation() {
                return strMargin()
            }
            key = "DVB-S2 \(constellation) \(fec)"
        default:
            return strMargin()
    }
    let dblMer = Double(mer) ?? 0.0
    let dblTheshold = LM_MOD_THRESHOLD[key] ?? 0.0
    // TODO: this can fail unwarpping optional - FIXED
    return strMargin(dblMer - dblTheshold)
}
