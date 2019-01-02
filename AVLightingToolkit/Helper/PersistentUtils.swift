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
