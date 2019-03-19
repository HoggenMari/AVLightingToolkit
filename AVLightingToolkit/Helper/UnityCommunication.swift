//
//  UnityCommunication.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 18.03.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import SwiftyJSON
import CocoaAsyncSocket


class UnityCommunication: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = UnityCommunication()
    
    var broadcastConnection: UDPBroadcastConnection!

    var socket: GCDAsyncUdpSocket?
    
    weak var timer: Timer!
    
    override init() {
        super.init()
        print("init")
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.bind(toPort: 6455)
            try socket?.enableBroadcast(true)
            try socket?.beginReceiving()
        } catch _ as NSError {
            print(">>>Issue with setting up listener")
        }
        print(socket?.localAddress()?.description)
        
        timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        /*broadcastConnection = UDPBroadcastConnection(port: UInt16(PORT)) { (ipAddress: String, port: Int, response: [UInt8]) -> Void in
            let response = "Received from \(ipAddress):\(port):\n\n\(response)"
            print(response)
        }*/
    }
    
    @objc func runTimedCode() {
        let string = "test"
        print(string)
        //socket?.send(string.data(using: String.Encoding.utf8)!, withTimeout: 0, tag: 0)
        socket?.send(string.data(using: String.Encoding.utf8)!, toHost: "255.255.255.255", port: 6454, withTimeout: 0, tag: 0)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("received")
        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print("Received: \(str)")
            
        }
    }
    
    
}
