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
        
        let lightPattern1 = allLightPatterns.filter({ (l: LightPattern) -> Bool in
            return l.name == "LightTestPattern"
        }).first
        
        let contexts = [
            (imageFilename: "context1", name: "Car is driving and will slow down", position: 1, lightpattern: ["Speed as colours vertically", "Speed as colours horizontally", "Speed as spatial information", "Speed as spatial information + effects"]),
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
            (imageFilename: "20181226_1", name: "Speed as colours vertically", position:1, code: "var mapToNative = function(leds,num) { return test.map(function (led, index) { if(index>=0 && index<=6) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index, 7),interpolate(color1.getGreen(), color2.getGreen(), index, 7), interpolate(color1.getBlue(), color2.getBlue(), index, 7));} else if(index>=7 && index<=13) { return LED.setAllWithRedGreenBlue(color2.getRed(),color2.getGreen(),color2.getBlue());} else if(index>=14 && index<=20){return LED.setAllWithRedGreenBlue(interpolate(color2.getRed(), color1.getRed(), index-14, 7),interpolate(color2.getGreen(), color1.getGreen(), index-14, 7), interpolate(color2.getBlue(), color1.getBlue(), index-14, 7));}})}; function interpolate(start, end, step, last) { return (end - start ) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181226_2", name: "Speed as colours horizontally", position:2, code: "var mapToNative = function(leds,num) { return test.map(function (led, index) { if(index>=0 && index<=6) { return LED.setAllWithRedGreenBlue(0,0,0);} else if(index>=7 && index<=10) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index-7, 3),interpolate(color1.getGreen(), color2.getGreen(), index-7, 3), interpolate(color1.getBlue(), color2.getBlue(), index-7, 3));} else if(index>=11 && index<=13) { return LED.setAllWithRedGreenBlue(interpolate(color2.getRed(), color1.getRed(), index-9, 3),interpolate(color2.getGreen(), color1.getGreen(), index-9, 3), interpolate(color2.getBlue(), color1.getBlue(), index-9, 3));} else if(index>=14 && index<=21){ return LED.setAllWithRedGreenBlue(0,0,0);}})}; function interpolate(start, end, step, last) { return (end - start ) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181018_1", name: "Speed as spatial information", position:3, code: "var mapToNative = function(leds,num) { return test.map(function (led, index) { if(index>=0 && index<=7) { return LED.setAllWithRedGreenBlue(0,0,0);} else if(index>=8 && index<=11) { return LED.setAllWithRedGreenBlue(interpolate(color1.getRed(), color2.getRed(), index-8, 4)*loop,interpolate(color1.getGreen(), color2.getGreen(), index-8, 4)*loop, interpolate(color1.getBlue(), color2.getBlue(), index-8, 4)*loop);} else if(index>=12 && index<=15) { return LED.setAllWithRedGreenBlue(interpolate(color2.getRed(), color1.getRed(), index-11, 4)*loop,interpolate(color2.getGreen(), color1.getGreen(), index-11, 4)*loop, interpolate(color2.getBlue(), color1.getBlue(), index-11, 4)*loop);} else if(index>=16 && index<=23){ return LED.setAllWithRedGreenBlue(0,0,0);}})}; function interpolate(start, end, step, last) { return (end - start ) * step / last + start; }", color1: UIColor.red, color2: UIColor.green),
            (imageFilename: "20181125_4(2)", name: "Speed as spatial information + effects", position:4, code: "var leds;", color1: UIColor.red, color2: nil),
            //(imageFilename: "20181125_1", name: "Identify as colours", position:5, code: "var leds;", color1: UIColor.red, color2: nil),
            //(imageFilename: "20181125_2", name: "Direction as movements", position:6, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_6(2)", name: "Notification as effects", position:5, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181018_2", name: "Notification as colours + effects", position:6, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_7(2)", name: "Direction as spatial information", position:7, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_8(2)", name: "Direction as spatial information + effects", position:8, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181018_3", name: "Direction as colours + spatial information + effects", position:9, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_5(2)", name: "Direction as movements", position:10, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_9", name: "Waiting as effects + identification with colours", position:11, code: "var leds;", color1: UIColor.red, color2: nil),
            (imageFilename: "20181125_10(2)", name: "Waiting as movement + identification with colours", position:12, code: "var leds;", color1: UIColor.red, color2: nil),
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
