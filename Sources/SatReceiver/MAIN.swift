//  -------------------------------------------------------------------
//  File: MAIN.swift
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
import Yams

let logProgress = false
let logErrors = true

func logProgress(_ str: String) {
    if logProgress {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = format.string(from: date)
        print("\(timestamp) - \(str)")
    }
}

func logError(_ str: String) {
    if logErrors {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = format.string(from: date)
        print("\(timestamp) - ERROR: \(str)")
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

// YAML from https://github.com/jpsim/Yams
struct YAMLConfig: Codable {
    var SVR_Host = "satserver.local"
    var SVR_Port = 8002
    var TS_Host = "office.local"
    var TS_Port = 7777
}

func readYaml() -> YAMLConfig {
    var config = YAMLConfig()
    let filename = "/home/pirec/configSatReceiver.yaml"
    
    do {
        // read configuration
        let yaml = try String(contentsOfFile: filename)
        let decoder = YAMLDecoder()
        config = try decoder.decode(YAMLConfig.self, from: yaml)
    } catch {
        // write default YAML configuration
        logError("MAIN.\(#function) : failed to read \(filename)")
        logProgress("MAIN.\(#function) : creating default configuration file")
        let defaultConfig = YAMLConfig()
        let encoder = YAMLEncoder()
        let encodedYAML = try! encoder.encode(defaultConfig)
        do {
            try encodedYAML.write(toFile: filename, atomically: true, encoding: .utf8)
        } catch {
            logError("MAIN.\(#function) : failed to write to: \(filename)")
            fatalError()
        }
    }
    return config
}

var signalReceived: sig_atomic_t = 0

@main
struct MAIN {
    static func main() {
//#if os(Linux)
        signal(SIGINT) { signal in signalReceived = SIGINT }
        signal(SIGTERM) { signal in signalReceived = SIGTERM }
        let config = readYaml()
        let TS_IP = ipFromString(config.TS_Host)
        let TS_Port = String(config.TS_Port)
        let receiver = Receiver(config: config, TS_IP: TS_IP, TS_Port: TS_Port)
        receiver.startRunning()
        while receiver.isRunning && signalReceived == sig_atomic_t(0) {
            sleep(1)
        }
        receiver.stopRunning()
        logProgress("MAIN.\(#function) : will shutdown with \(signalReceived)")
        sleep(1)
        rPiPowerOff()
        //system(shutdown(<#T##Int32#>, <#T##Int32#>))
        exit(signalReceived)
//#else
//        print("SatReceiver can only run on Linux")
//#endif
    }
}
