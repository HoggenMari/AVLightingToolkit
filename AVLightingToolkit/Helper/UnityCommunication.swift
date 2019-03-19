//
//  UnityCommunication.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 18.03.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import SwiftyJSON

class UnityCommunication {
    
    static let sharedInstance = UnityCommunication()

    var broadcastConnection: UDPBroadcastConnection!
    let PORT: Int32 = 6455

    init() {
        broadcastConnection = UDPBroadcastConnection(port: UInt16(PORT)) { (ipAddress: String, port: Int, response: [UInt8]) -> Void in
            let response = "Received from \(ipAddress):\(port):\n\n\(response)"
            print(response)
        }
    }
    
}
