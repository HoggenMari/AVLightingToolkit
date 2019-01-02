//
//  LightPatternViewModel.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 02.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData

class LightPatternViewModel {
    
    var currentLightPattern: LightPattern?
    var fetchedResultController: NSFetchedResultsController<LightPattern>?
    
    init() {
        fetchedResultController = NSFetchedResultsController(fetchRequest: lightpatternFetchRequest(),
                                                             managedObjectContext: PersistentUtils.sharedInstance.coreDataStack.mainContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
    }
    
    func lightpatternFetchRequest() -> NSFetchRequest<LightPattern> {
        let fetchRequest:NSFetchRequest<LightPattern> = LightPattern.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(LightPattern.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func initializeFetchController(_ aDelegate: NSFetchedResultsControllerDelegate) {
        fetchedResultController?.delegate = aDelegate
        do {
            try fetchedResultController?.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func createNewLightPattern() -> LightPattern? {
        currentLightPattern = LightPattern(context: PersistentUtils.sharedInstance.coreDataStack.mainContext)
        return currentLightPattern
    }

    var numberOfLightPatterns: Int {
        if let results = fetchedResultController?.fetchedObjects {
            return results.count
        }
        return 0
    }
    
    func lightPattern(at indexpath: IndexPath) -> LightPattern? {
        return fetchedResultController?.object(at: indexpath)
    }
    
    func lightPattern(for index: Int) -> LightPattern? {
        return fetchedResultController?.fetchedObjects?[index]
    }
    
    func saveCurrentLightPattern() {
        if let context = currentLightPattern?.managedObjectContext {
            context.perform {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Error: \(error.localizedDescription)")
                }
                PersistentUtils.sharedInstance.coreDataStack.saveContext()
            }
        }
    }
    
    func clearCurrentLightPattern() {
        if let item = currentLightPattern {
            PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(item)
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }
        return
    }
}
