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

protocol UnityCommunicationDelegate {
    func newClientDidConntected()
}

protocol UnityContextDelegate {
    func contextActivated(_ id: Int)
}

class UnityCommunication: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {
    
    static let sharedInstance = UnityCommunication()
    
    var socket: GCDAsyncUdpSocket?
    var receiveSocket: GCDAsyncUdpSocket?
    
    var serverSocket: GCDAsyncSocket?
    var clientSocket = [GCDAsyncSocket?]()

    weak var timer: Timer!
    var count = 0
    
    var delegate: UnityCommunicationDelegate?
    
    var contextDelegate: UnityContextDelegate?
    
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
        
        serverSocket = GCDAsyncSocket(delegate: self as? GCDAsyncSocketDelegate, delegateQueue: DispatchQueue.main)
        
        do {
            try serverSocket?.accept(onPort: 5566)
            print("port succuess")
        }catch {
            print("port fail")
        }
        
    }
    
    func sendData(_ data: Data) {
        socket?.send(data, toHost: "255.255.255.255", port: 6454, withTimeout: 0, tag: 0)

    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        //print(address)
        //print("received")
        if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            //print("Received: \(str)")
            
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        print("connect succuess")
        print("connect to " + newSocket.connectedHost!)
        print("port" + String(newSocket.connectedPort))
        clientSocket.append(newSocket)
        delegate?.newClientDidConntected()
        
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("data.count: \(data.count)")
        let dataString:String = String(data: data as Data, encoding: String.Encoding.utf8)!
        print(dataString)
        
        if let dataFromString = dataString.data(using: .utf8, allowLossyConversion: false) {
            do {
                let json = try JSON(data: dataFromString)
                if let id = json["id"].int {
                    contextDelegate?.contextActivated(id)
                }
                print(json)
            }catch{
                print("error")
            }
        }
        
        //let dataJson = JSON.init(parseJSON: dataString)
        
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
        
    }
    
    func sendDataToClients(_ data: Data) {
        for client in clientSocket {
            client?.write(data, withTimeout: -1, tag: 0)
        }
    }
    
}
