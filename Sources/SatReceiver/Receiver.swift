//  -------------------------------------------------------------------
//  File: Receiver.swift
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
import NIOCore
import NIOPosix
import NIOFoundationCompat

final class Receiver {
    private let rPiTemperature = PiTemperature()
    private let longmynd: Longmynd
    private var isStopping = false
    private var connected = false
    
    private var SVR_Host: String
    private var SVR_Port: Int
    
    var isRunning = true
    
    private var client: NIO_TCP_Client?
    
    init(config: YAMLConfig, TS_IP: String, TS_Port: String) {
        self.SVR_Host = config.SVR_Host
        self.SVR_Port = config.SVR_Port
        self.longmynd = Longmynd(TS_IP: TS_IP, TS_Port: TS_Port)
    }
    
    func startRunning() {
        logProgress("Receiver.\(#function) : start running")
        longmynd.startRunning()
        connectNetwork(host: SVR_Host, port: SVR_Port)
        consumeData()
    }
    
    func stopRunning() {
        logProgress("Receiver.\(#function) : start stopping")
        longmynd.stopRunning()
        while true {
            let running = longmynd.isRunning
            if !running {
                break
            }
        }
        isStopping = true
        while isStopping {
            // print(".")
            // await Task.yield()
            Task { try await Task.sleep(seconds: 0.1) }
//            await Task.yield()
        }
        encodeAndSend(newValues: RxStatusAPI(state: .ShuttingDown))
        clientDisconnect()
        logProgress("Receiver.\(#function) : has stopped")
    }
    
    // MARK: This is the long-running work thread
    private func consumeData() {
        Task {
            while !isStopping {
                var newValues = longmynd.newValues()
                newValues.temperature = await rPiTemperature.value()
                encodeAndSend(newValues: newValues)
                await Task.yield()
                try await Task.sleep(seconds: 3)
            }
            isStopping = false
        }
    }
    
    // MARK: Network Functions
    
    private func encodeAndSend(newValues: RxStatusAPI) {
        logProgress("Receiver.\(#function) : connected = \(connected)")
        if connected {
            do {
                let data =  try JSONEncoder().encode(newValues)
                client?.send(data)
                logProgress("Receiver.\(#function) : SENT->SATSERVER with status \(newValues.state)")
            } catch {
                logError("Receiver.\(#function) : failed to send: \(error)")
            }
        } else {
            logError("Receiver.\(#function) : not connected so failed to send")
        }
    }
    
    private func callbackFromSatServer(_ data: Data) {
        do {
            let requestFromSatServer = try JSONDecoder().decode(RxCommandAPI.self, from: data)
            logProgress("Receiver.\(#function) : got \(requestFromSatServer)")
            switch requestFromSatServer.action {
                case .Configure:
                    Task {
                        longmynd.configure(freq: requestFromSatServer.freq, srs: requestFromSatServer.srs)
                    }
                case .Calibrate:
                    Task {
                        longmynd.calibrate()
                    }
                case .Shutdown:
                    isRunning = false
            }
        } catch {
            logError("Receiver.\(#function) : failed to decode: \(error)")
        }
    }
    
    private func connectNetwork(host: String, port: Int) {
        logProgress("Receiver.\(#function)) : \(host) \(port)")
        do {
            client = try NIO_TCP_Client.connect(host: host, port: port, callbackFromSatServer)
            logProgress("Receiver.\(#function)) : connected to \(host):\(port)")
            connected = true
        } catch {
            logError("Receiver.\(#function) : failed to connect to \(host):\(port)")
            connected = false
        }
    }
    
    private func clientDisconnect() {
        if connected {
            client?.disconnect()
        }
    }
}
