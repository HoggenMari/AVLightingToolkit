//
//  LEDController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 28.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import SwiftSocket

class LEDController {
    
    static let sharedInstance = LEDController()
    
    let IP_ADDRESS = "172.20.10.2"
    let PORT: Int32 = 6454
    let header = Data( hex:"4172742D4e6574305050ffffffffffff0f00")

    var client: UDPClient?
    var data: Data?
    var timer: Timer!

    var n = 16
    
    init() {
        client = UDPClient(address: IP_ADDRESS, port: PORT)
    
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    @objc func runTimedCode() {
        data = Data()
        data?.append(header)
        
        let red = NSString(format:"%2X", n) as String
        
        for _ in 1...10 {
            data?.append(Data(hex:red))
            data?.append(Data(hex:"a0b0"))
        }
        
        if let sendData = data {
            client?.send(data: sendData)
        }
        
        if n >= 100 {
            n = 16
        } else {
            n+=1
        }
    }
}

extension UnicodeScalar {
    var hexNibble:UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        }
        else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        }
        else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) not a legal hex nibble")
    }
}

extension Data {
    init(hex:String) {
        let scalars = hex.unicodeScalars
        var bytes = Array<UInt8>(repeating: 0, count: (scalars.count + 1) >> 1)
        for (index, scalar) in scalars.enumerated() {
            var nibble = scalar.hexNibble
            if index & 1 == 0 {
                nibble <<= 4
            }
            bytes[index >> 1] |= nibble
        }
        self = Data(bytes: bytes)
    }
}
