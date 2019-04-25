//
//  PersistentUtils.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 30.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistentUtils {
    
    static let sharedInstance = PersistentUtils()

    lazy var coreDataStack = CoreDataStack(modelName: "AVLightingToolkit")
    
    
    func seedContext() {
        
        let lightpatternFetchRequest = NSFetchRequest<LightPattern>(entityName: "LightPattern")
        let allLightPatterns = try! coreDataStack.mainContext.fetch(lightpatternFetchRequest)
        
        _ = allLightPatterns.filter({ (l: LightPattern) -> Bool in
            return l.name == "LightTestPattern"
        }).first
        
        let contexts = [
            (imageFilename: "context1", name: "Car is driving and will slow down", position: 1, lightpattern: ["Speed as colours", "Speed as colours vertically", "Speed as colours horizontally", "Speed as spatial information", "Speed as spatial information + effects"]),
            (imageFilename: "context2", name: "Car is detecting another person", position: 2, lightpattern: ["Notification as effects", "Notification as colours + effects"]),
            (imageFilename: "context3", name: "Car is indicating to pull down", position: 3, lightpattern: ["Direction as spatial information", "Direction as spatial information + effects", "Direction as colours + spatial information + effects", "Direction as movements"]),
            (imageFilename: "context4", name: "Car is picking up a person", position: 4, lightpattern: ["Waiting as effects + identification with colours", "Waiting as movement + identification with colours"])
        ]
        
        for context in contexts {
            let newContext = NSEntityDescription.insertNewObject(forEntityName: "Context", into: coreDataStack.mainContext) as! Context
            newContext.imageFilename = context.imageFilename
            newContext.name = context.name
            newContext.position = Int16(context.position)
            newContext.hidden = true
            newContext.active = false
            if (newContext.position == 1) {
                newContext.active = true
            }
            
            for lp in context.lightpattern {
                let lightPattern1 = allLightPatterns.filter({ (l: LightPattern) -> Bool in
                    return l.name == lp
                }).first
                if let lightPatternFound = lightPattern1 {
                    newContext.addToLightpatterns(lightPatternFound)
                }
            }
            
            //newContext.lightpatterns = lightPatternSet

        }
        
        do {
            try coreDataStack.mainContext.save()
        } catch _ {
        }
    }
    
    
    func seedLightPattern() {
        
        let lightpatterns = [
            (imageFilename: "", name: "Speed as colours", position:1, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), loop, 1), interpolate(color1.getGreen(), color2.getGreen(), loop, 1), interpolate(color1.getBlue(), color2.getBlue(), loop, 1)); }) }; function interpolate(start, end, step, last) { return (end - start) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181226_1", name: "Speed as colours vertically", position:2, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index >= parseInt(loop*(6-2+1)) && index <= 6) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index, 6), interpolate(color1.getGreen(), color2.getGreen(), index, 6), interpolate(color1.getBlue(), color2.getBlue(), index, 6)); } else if (index >= 7 && index <= 13) { return LED.setAllWithRedGreenBlue(0, 0, 0); } else if (index >= 14 && index <= 20-parseInt(loop*(20-16+1))) { return LED.setAllWithRedGreenBlue(interpolate(color2.getRed(), color1.getRed(), index - 14, 6), interpolate(color2.getGreen(), color1.getGreen(), index - 14, 6), interpolate(color2.getBlue(), color1.getBlue(), index - 14, 6)); } else return LED.setAllWithRedGreenBlue(0,0,0); }) }; function interpolate(start, end, step, last) { return (end - start) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181226_2", name: "Speed as colours horizontally", position:3, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index <= 6) { return LED.setAllWithRedGreenBlue(0, 0, 0); } else if (index > 6 + loop * (10 - 6) && index <= 10) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index - 6, 4), interpolate(color1.getGreen(), color2.getGreen(), index - 6, 4), interpolate(color1.getBlue(), color2.getBlue(), index - 6, 4)); } else if (index >= 10 && index < 14 - loop * (14 - 10)) { return LED.setAllWithRedGreenBlue(interpolate(color2.getRed(), color1.getRed(), index - 10, 4), interpolate(color2.getGreen(), color1.getGreen(), index - 10, 4), interpolate(color2.getBlue(), color1.getBlue(), index - 10, 4)); } else if (index >= 14) { return LED.setAllWithRedGreenBlue(0, 0, 0); } return LED.setAllWithRedGreenBlue(0, 0, 0); }) }; function interpolate(start, end, step, last) { return (end - start) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181018_1", name: "Speed as spatial information", position:4, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index >= parseInt(loop * (6 - 0 + 1)) && index <= 6) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else if (index >= 7 && index <= 13) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else if (index >= 14 && index <= 20 - parseInt(loop * (20 - 14 + 1))) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else return LED.setAllWithRedGreenBlue(0, 0, 0); }) };", color1: UIColor.white, color2: nil),
            (imageFilename: "20181125_4(2)", name: "Speed as spatial information + effects", position:5, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index >= 7 + parseInt(loop * (10 - 6)) && index <= 10) { return LED.setAllWithRedGreenBlue(interpolate(0.25*color1.getRed(), color1.getRed(), index - 6, 4), interpolate(0.25*color1.getGreen(), color1.getGreen(), index - 6, 4), interpolate(0.25*color1.getBlue(), color1.getBlue(), index - 6, 4)); } else if (index > 10 && index <= 13 - parseInt(loop * (14 - 10))) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), 0.25*color1.getRed(), index - 10, 4), interpolate(color1.getGreen(), 0.25*color1.getGreen(), index - 10, 4), interpolate(color1.getBlue(), 0.25*color1.getBlue(), index - 10, 4)); } else return LED.setAllWithRedGreenBlue(0, 0, 0); }) }; function interpolate(start, end, step, last) { return (end - start) * step / last + start; }", color1: UIColor.white, color2: nil),
            //(imageFilename: "20181125_1", name: "Identify as colours", position:5, code: "var leds;", color1: UIColor.red, color2: nil),
            //(imageFilename: "20181125_2", name: "Direction as movements", position:6, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_6(2)", name: "Notification as effects", position:6, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index ==10) { return LED.setAllWithRedGreenBlue(color1.getRed()* 2 * Math.min(loop, 1 - loop), color1.getGreen()* 2 * Math.min(loop, 1 - loop), color1.getBlue()* 2 * Math.min(loop, 1 - loop)); } else if (index >= 9 && index <= 11) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.9* 2 * Math.min(loop, 1 - loop), color1.getGreen()*0.9* 2 * Math.min(loop, 1 - loop), color1.getBlue()*0.9* 2 * Math.min(loop, 1 - loop)); } else if (index >= 8 && index <= 12) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.5* 2 * Math.min(loop, 1 - loop), color1.getGreen()*0.5* 2 * Math.min(loop, 1 - loop), color1.getBlue()*0.5* 2 * Math.min(loop, 1 - loop)); } else if (index >= 7 && index <= 13) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.25* 2 * Math.min(loop, 1 - loop), color1.getGreen()*0.25* 2 * Math.min(loop, 1 - loop), color1.getBlue()*0.25* 2 * Math.min(loop, 1 - loop)); } else return LED.setAllWithRedGreenBlue(0,0,0); }) };", color1: UIColor.white, color2: nil),
            (imageFilename: "20181018_2", name: "Notification as colours + effects", position:7, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (loop <= 0.05 || (loop >= 0.1 & loop <= 0.15) || (loop >= 0.3 && loop <= 0.35) || (loop >= 0.4 && loop <= 0.45) || (loop >= 0.6 & loop <= 0.65) || (loop >= 0.7 && loop <= 0.75)) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else { return LED.setAllWithRedGreenBlue(255, 255, 255); } }) };", color1: UIColor.yellow, color2: nil),
            //(imageFilename: "20181125_7(2)", name: "Direction as spatial information", position:7, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_8(2)", name: "Direction as spatial information + effects", position:8, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index >=7 && index <=13) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else { if (loop <= 0.05 || (loop >= 0.1 & loop <= 0.15) || (loop >= 0.2 && loop <= 0.25) || (loop >= 0.50 && loop <= 0.55) || (loop >= 0.6 & loop <= 0.65) || (loop >= 0.7 && loop <= 0.75)) { if (index <= 20 && index >= 14) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else return LED.setAllWithRedGreenBlue(0, 0, 0); } else { return LED.setAllWithRedGreenBlue(0, 0, 0); } } }) };", color1: UIColor.white, color2: nil),
            (imageFilename: "20181018_3", name: "Direction as colours + spatial information + effects", position:9, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (loop <= 0.05 || (loop >= 0.1 & loop <= 0.15) || (loop >= 0.2 && loop <= 0.25) || (loop >= 0.50 && loop <= 0.55) || (loop >= 0.6 & loop <= 0.65) || (loop >= 0.7 && loop <= 0.75)) { if (index <= 20 && index >= 14) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else return LED.setAllWithRedGreenBlue(255, 255, 255); } else { return LED.setAllWithRedGreenBlue(255, 255, 255); } }) };", color1: UIColor.yellow, color2: nil),
            (imageFilename: "20181125_5(2)", name: "Direction as movements", position:10, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (loop <= 0.5) { var pos1 = parseInt((loop - 0)*(18-10)/(0.5 - 0) + 10, 10); if (index == pos1) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else if (index == (pos1 - 1) || index == (pos1 + 1)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.5, color1.getGreen()*0.5, color1.getBlue()*0.5); } else if (index == (pos1 - 2) || index == (pos1 + 2)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.25, color1.getGreen()*0.25, color1.getBlue()*0.25); } else return LED.setAllWithRedGreenBlue(0,0,0); } else { var pos2 = parseInt((loop - 0.5)*(10-18)/(1 - 0.5) + 18, 10)+1; if (index == pos2) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); }else if (index == (pos2 - 1) || index == (pos2 + 1)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.5, color1.getGreen()*0.5, color1.getBlue()*0.5); } else if (index == (pos2 - 2) || index == (pos2 + 2)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.25, color1.getGreen()*0.25, color1.getBlue()*0.25); } else return LED.setAllWithRedGreenBlue(0,0,0); } }) };", color1: UIColor.white, color2: nil),
            (imageFilename: "20181125_9", name: "Waiting as effects + identification with colours", position:11, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (index >= 0 && index <= 6) { return LED.setAllWithRedGreenBlue(0, 0, 0); } else if (index >= 7 && index <= 13) { return LED.setAllWithRedGreenBlue(color1.getRed() * 2 * Math.min(loop, 1 - loop), color1.getGreen() * 2 * Math.min(loop, 1 - loop), color1.getBlue() * 2 * Math.min(loop, 1 - loop)); } else if (index >= 14 && index <= 20) { return LED.setAllWithRedGreenBlue(0, 0, 0); } }) };", color1: UIColor.purple, color2: nil),
            (imageFilename: "20181125_10(2)", name: "Waiting as movement + identification with colours", position:12, code: "var mapToNative = function(leds, num) { return test.map(function(led, index) { if (loop <= 0.8) { var pos1 = parseInt((loop - 0)*(8-1)/(0.8 - 0) + 1, 10); var pos2 = parseInt((loop - 0)*(12-19)/(0.8 - 0) + 19, 10)+1; if (index == pos1) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); } else if (index == (pos1 - 1) || index == (pos1 + 1)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.5, color1.getGreen()*0.5, color1.getBlue()*0.5); } else if (index == (pos1 - 2) || index == (pos1 + 2)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.25, color1.getGreen()*0.25, color1.getBlue()*0.25); } else if (index == pos2) { return LED.setAllWithRedGreenBlue(color1.getRed(), color1.getGreen(), color1.getBlue()); }else if (index == (pos2 - 1) || index == (pos2 + 1)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.5, color1.getGreen()*0.5, color1.getBlue()*0.5); } else if (index == (pos2 - 2) || index == (pos2 + 2)) { return LED.setAllWithRedGreenBlue(color1.getRed()*0.25, color1.getGreen()*0.25, color1.getBlue()*0.25); } else return LED.setAllWithRedGreenBlue(0,0,0); } else if (index == 10) { return LED.setAllWithRedGreenBlue(color1.getRed()*loop, color1.getGreen()*loop, color1.getBlue()*loop); } else return LED.setAllWithRedGreenBlue(0,0,0); }) };", color1: UIColor.purple, color2: nil),
            //(imageFilename: "20181125_10", name: "Waiting as movements", position:14, code: "var leds;", color1: UIColor.red, color2: nil)

        ]
        
        for lightpattern in lightpatterns {
            let newLightPattern = NSEntityDescription.insertNewObject(forEntityName: "LightPattern", into: coreDataStack.mainContext) as! LightPattern
            newLightPattern.name = lightpattern.name
            newLightPattern.position = Int16(lightpattern.position)
            newLightPattern.code = lightpattern.code
            newLightPattern.imageFilename = lightpattern.imageFilename
            if lightpattern.color1 != nil {
                var c1 = UIColor.clear
                c1 = lightpattern.color1 ?? UIColor.clear
                newLightPattern.color1 = c1.encode()
            }
            if lightpattern.color2 != nil {
                var c2 = UIColor.clear
                c2 = lightpattern.color2 ?? UIColor.clear
                newLightPattern.color2 = c2.encode()
            }
        }
        
        do {
            try coreDataStack.mainContext.save()
        } catch _ {
        }
        
    }
    
    /*func lightPatternFetchedResultsController() -> NSFetchedResultsController<LightPattern> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: lightPatternFetchRequest(),
                                                                 managedObjectContext: coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func lightPatternFetchRequest() -> NSFetchRequest<LightPattern> {
        let fetchRequest:NSFetchRequest<LightPattern> = LightPattern.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(LightPattern.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }*/
    
}
