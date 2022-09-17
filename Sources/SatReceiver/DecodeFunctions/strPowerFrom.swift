//
//  strPowerFrom.swift
//  -------------------------------------------------------------------
//  File: strCPowerFrom.swift
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

func strPowerFrom(agc1: Int, agc2: Int) -> String {
    // Returns power in dBm
    // See: https://wiki.batc.org.uk/MiniTiouner_Power_Level_Indication
    // Note: make different colour if too low (less than -70 dB)
    //        logProgress("Longmynd.\(#function) : agc1 \(agc1) agc2 \(agc2)")
    
    // experimental
    //    if agc2 == 0 {
    //        return strPower()
    //    }
    
    if agc1 == 0 {
        switch agc2 {
            case 2740+1...3200:   return strPower(-97)
            case 2560+1...2740:   return strPower(-96)
            case 2380+1...2560:   return strPower(-95)
            case 2200+1...2380:   return strPower(-94)
            case 2020+1...2200:   return strPower(-93)
            case 1840+1...2020:   return strPower(-92)
            case 1660+1...1840:   return strPower(-91)
            case 1480+1...1660:   return strPower(-90)
            case 1300+1...1480:   return strPower(-89)
            case 1140+1...1300:   return strPower(-88)
            case 1000+1...1140:   return strPower(-87)
            case 880+1...1000:    return strPower(-86)
            case 780+1...880:     return strPower(-85)
            case 700+1...780:     return strPower(-84)
            case 625+1...700:     return strPower(-83)
            case 560+1...625:     return strPower(-82)
            case 500+1...560:     return strPower(-81)
            case 450+1...500:     return strPower(-80)
            case 400+1...450:     return strPower(-79)
            case 360+1...400:     return strPower(-78)
            case 325+1...360:     return strPower(-77)
            case 290+1...325:     return strPower(-76)
            case 255+1...290:     return strPower(-75)
            case 225+1...255:     return strPower(-74)
            case 200+1...225:     return strPower(-73)
            case 182+1...200:     return strPower(-72)
            case 164+1...182:     return strPower(-71)
                // case 149+1...164:     return strPower(-70)
            default:
                break
        }
    } else {
        switch agc1 {
            case 1...10-1:        return strPower(-70)
            case 10...2180-1:     return strPower(-69)
            case 21800...25100-1: return strPower(-68)
            case 25100...27100-1: return strPower(-67)
            case 27100...28100-1: return strPower(-66)
            case 28100...28900-1: return strPower(-65)
            case 28900...29600-1: return strPower(-64)
            case 29600...30100-1: return strPower(-63)
            case 30100...30550-1: return strPower(-62)
            case 30550...31000-1: return strPower(-61)
            case 31000...31350-1: return strPower(-60)
            case 31350...31700-1: return strPower(-59)
            case 31700...32050-1: return strPower(-58)
            case 32050...32400-1: return strPower(-57)
            case 32400...32700-1: return strPower(-56)
            case 32700...33000-1: return strPower(-55)
            case 33000...33300-1: return strPower(-54)
            case 33300...33600-1: return strPower(-53)
            case 33600...33900-1: return strPower(-52)
            case 33900...34200-1: return strPower(-51)
            case 34200...34500-1: return strPower(-50)
            case 34500...34750-1: return strPower(-49)
            case 34750...35000-1: return strPower(-48)
            case 35000...35000-1: return strPower(-47)
            case 35000...35500-1: return strPower(-46)
            case 35500...35750-1: return strPower(-45)
            case 35750...36000-1: return strPower(-44)
            case 36000...36200-1: return strPower(-43)
            case 36200...36400-1: return strPower(-42)
            case 36400...36600-1: return strPower(-41)
            case 36600...36800-1: return strPower(-40)
            case 36800...37000-1: return strPower(-39)
            case 37000...37200-1: return strPower(-38)
            case 37200...37400-1: return strPower(-37)
            case 37400...37600-1: return strPower(-36)
            case 37600...37700-1: return strPower(-35)
            case 37700:           return strPower(-35, over: true)
            default:
                break
        }
    }
    return strPower()
}
