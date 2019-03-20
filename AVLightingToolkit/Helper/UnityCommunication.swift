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
    
    var socket: GCDAsyncUdpSocket?
    var receiveSocket: GCDAsyncUdpSocket?

    weak var timer: Timer!
    
    override init() {
        super.init()
        print("init")
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.bind(toPort: 6454)
            try socket?.enableBroadcast(true)
            try socket?.beginReceiving()
        } catch _ as NSError {
            print(">>>Issue with setting up listener")
        }
        
        receiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try receiveSocket?.bind(toPort: 6455)
            try receiveSocket?.enableBroadcast(true)
            try receiveSocket?.beginReceiving()
        } catch _ as NSError {
            print(">>>Issue with setting up listener")
        }
        
    }
    
    func sendData(_ data: Data) {
        socket?.send(data, toHost: "255.255.255.255", port: 6454, withTimeout: 0, tag: 0)

    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print(address)
        print("received")
        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print("Received: \(str)")
            
        }
    }
    
    
}
