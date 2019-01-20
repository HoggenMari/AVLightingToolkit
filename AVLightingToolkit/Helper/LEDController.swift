//
//  LEDController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 28.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import SwiftSocket
import JavaScriptCore

@objc
protocol LEDJSExports : JSExport {
    var red: Int { get set }
    var green: Int { get set }
    var blue: Int { get set }
    
    static func setAllWith(red: Int, green: Int, blue: Int) -> LED
    func getRed() -> Int
    func getGreen() -> Int
    func getBlue() -> Int
    
}

@objc
public class LED : NSObject, LEDJSExports {
    dynamic var red: Int
    
    dynamic var green: Int
    
    dynamic var blue: Int
    
    override init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public class func setAllWith(red: Int, green: Int, blue: Int) -> LED {

        return LED(red: red, green: green, blue: blue)
    }
    
    func getRed() -> Int {
        return red
    }
    
    func getGreen() -> Int {
        return green
    }
    
    func getBlue() -> Int {
        return blue
    }
    
    
}

class LEDController {
    
    static let sharedInstance = LEDController()
    
    let IP_ADDRESS = "172.20.10.2"
    let PORT: Int32 = 6454
    let header = Data( hex:"4172742D4e6574305050ffffffffffff0f00")

    var client: UDPClient?
    var data: Data?
    weak var timer: Timer!
    
    var red = NSString(format:"%2X", 100) as String

    var loop = 0
    
    var brightness = 0.5
    
    var colorVal1: UIColor = UIColor.red
    var colorVal2: UIColor = UIColor.green
    
    var code: String!
    
    init() {
        client = UDPClient(address: IP_ADDRESS, port: PORT)
    
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    func play(_ code: String) {
        self.code = code
    }
    
    @objc func runTimedCode() {
        data = Data()
        data?.append(header)
        
        let context = JSContext()
        
        context?.exceptionHandler = { context, exception in
            let error = exception
            print("JS Error: \(String(describing: error))")
        }
        
        
        var test = [LED]()
        //test.reserveCapacity(10)
        
        for _ in 0...9 {
            test.append(LED())
        }
        
        loop+=1
        if(loop > 255) {
            loop = 0
        }
        

        let red1 = colorVal1.getRGBAComponents()?.red
        let green1 = colorVal1.getRGBAComponents()?.green
        let blue1 = colorVal1.getRGBAComponents()?.blue
        let color1 = LED.init(red: Int(red1!*255), green: Int(green1!*255), blue: Int(blue1!*255))
        
        let red2 = colorVal2.getRGBAComponents()?.red
        let green2 = colorVal2.getRGBAComponents()?.green
        let blue2 = colorVal2.getRGBAComponents()?.blue
        let color2 = LED.init(red: Int(red2!*255), green: Int(green2!*255), blue: Int(blue2!*255))

        context?.setObject(LED.self, forKeyedSubscript: "LED" as NSCopying & NSObjectProtocol)
        context?.setObject(test, forKeyedSubscript: "test" as NSCopying & NSObjectProtocol)
        context?.setObject(loop, forKeyedSubscript: "loop" as NSCopying & NSObjectProtocol)
        context?.setObject(color1, forKeyedSubscript: "color1" as NSCopying & NSObjectProtocol)
        context?.setObject(color2, forKeyedSubscript: "color2" as NSCopying & NSObjectProtocol)

        let ledScript = "var mapToNative = function(leds,num) { var leds = new Array(num); return test.map(function (led, index) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index, num),interpolate(color1.getGreen(), color2.getGreen(), index, num), interpolate(color1.getBlue(), color2.getBlue(), index, num));})}; function interpolate(start, end, step, last) { return (end - start ) * step / last + start; }"

        guard let c = code else {
            return
        }
        context?.evaluateScript(c)
        
        let mapFunction = context?.objectForKeyedSubscript("mapToNative")
        let leds = mapFunction?.call(withArguments: [10,10]).toArray() as? [LED]
        
        for i in 0...test.count-1 {
            let red = leds?[i].getRed().convertToData(brightness)
            let green = leds?[i].getGreen().convertToData(brightness)
            let blue = leds?[i].getBlue().convertToData(brightness)
            data?.append(red!)
            data?.append(green!)
            data?.append(blue!)
        }
        
        if let sendData = data {
            client?.send(data: sendData)
        }
    
    }
    
    func setColor1(_ color: UIColor) {
        colorVal1 = color
    }
    
    func setColor2(_ color: UIColor) {
        colorVal2 = color
    }
    
    func setBrightness(_ value: Double) {
        brightness = value
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

extension Int {
    func convertToData(_ brightness: Double) -> Data {
        var v = Int(Double(self) * brightness)
        return Data(bytes: &v, count: MemoryLayout<Byte>.size)
    }
}
