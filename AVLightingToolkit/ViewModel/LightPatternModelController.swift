//
//  LightPatternViewModel.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 02.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData

class LightPatternModelController {
    
    var currentLightPattern: LightPattern?
    var fetchedResultController: NSFetchedResultsController<LightPattern>?
    var childContext: NSManagedObjectContext!
    
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
        currentLightPattern?.position = Int16(numberOfLightPatterns)
        return currentLightPattern
    }
    
    func cloneLightPattern(_ id: NSManagedObjectID) -> LightPattern? {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = PersistentUtils.sharedInstance.coreDataStack.mainContext
        currentLightPattern = childContext.object(with: id) as? LightPattern
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
    
    func deleteLightPattern(at section: Int) {
        //let sections = fetchedResultController?.fetchedObjects?[section]
        //PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(sections!)
        //PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
        
        let sections = fetchedResultController?.fetchedObjects?[section]
        PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(sections!)
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
        guard let sectionUpperBound = fetchedResultController?.fetchedObjects?.count, sectionUpperBound > section + 1 else {
            return
        }
        
        for n in section...sectionUpperBound - 1 {
            let pattern = fetchedResultController?.fetchedObjects?[n]
            pattern?.position = Int16(n)
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }
        
    }
    
    func deleteAllLightPatterns() {
        
        if numberOfLightPatterns <= 0 {
            return
        }
        
        for n in 0...numberOfLightPatterns - 1{
            deleteLightPattern(at: (numberOfLightPatterns - 1) - n)
        }
    }
}
