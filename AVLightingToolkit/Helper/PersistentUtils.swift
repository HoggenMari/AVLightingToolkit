//
//  PersistentUtils.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 30.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData

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
            (imageFilename: "context1", name: "Car is driving and will slow down", position: 1, lightpattern: ["Speed as colours vertically", "Speed as colours horizontally", "Speed as spatial information", "Speed as spatial information + effects", "Identify as colours", "Direction as movements"]),
            (imageFilename: "context2", name: "Car is detecting another person", position: 2, lightpattern: ["Notification as effects", "Notification as colours + effects"]),
            (imageFilename: "context3", name: "Car is indicating to pull down", position: 3, lightpattern: ["Direction as spatial information", "Direction as spatial information + effects", "Direction as colours + spatial information + effects"]),
            (imageFilename: "context4", name: "Car is picking up a person", position: 4, lightpattern: ["Waiting as effects", "Waiting as colours + effects", "Waiting as movements"])
        ]
        
        for context in contexts {
            let newContext = NSEntityDescription.insertNewObject(forEntityName: "Context", into: coreDataStack.mainContext) as! Context
            newContext.imageFilename = context.imageFilename
            newContext.name = context.name
            newContext.position = Int16(context.position)
            
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
            (imageFilename: "20181226_1", name: "Speed as colours vertically", code: "var mapToNative = function(leds,num) { return test.map(function (led) { return LED.setAllWithRedGreenBlue(color1.getRed(),color1.getGreen(),color1.getBlue());})};"),
            (imageFilename: "20181226_2", name: "Speed as colours horizontally", code: "var leds;"),
            (imageFilename: "20181018_1", name: "Speed as spatial information", code: "var leds;"),
            (imageFilename: "20181125_4", name: "Speed as spatial information + effects", code: "var leds;"),
            (imageFilename: "20181125_1", name: "Identify as colours", code: "var leds;"),
            (imageFilename: "20181125_2", name: "Direction as movements", code: "var leds;"),
            (imageFilename: "20181125_6", name: "Notification as effects", code: "var leds;"),
            (imageFilename: "20181018_2", name: "Notification as colours + effects", code: "var leds;"),
            (imageFilename: "20181125_7", name: "Direction as spatial information", code: "var leds;"),
            (imageFilename: "20181125_8", name: "Direction as spatial information + effects", code: "var leds;"),
            (imageFilename: "20181018_3", name: "Direction as colours + spatial information + effects", code: "var leds;"),
            (imageFilename: "20181125_9", name: "Waiting as effects", code: "var leds;"),
            (imageFilename: "20181018_4", name: "Waiting as colours + effects", code: "var leds;"),
            (imageFilename: "20181125_10", name: "Waiting as movements", code: "var leds;"),

        ]
        
        for lightpattern in lightpatterns {
            let newLightPattern = NSEntityDescription.insertNewObject(forEntityName: "LightPattern", into: coreDataStack.mainContext) as! LightPattern
            newLightPattern.name = lightpattern.name
            newLightPattern.code = lightpattern.code
            newLightPattern.imageFilename = lightpattern.imageFilename
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
