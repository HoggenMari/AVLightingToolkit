//
//  LightPatternViewModel.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 02.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class ContextModelController: UnityCommunicationDelegate {
    
    var currentContext: Context?
    var childContext: NSManagedObjectContext!
    var context: NSManagedObjectContext!
    
    var fetchedResultController: NSFetchedResultsController<Context>?
    
    init() {
        fetchedResultController = NSFetchedResultsController(fetchRequest: contextFetchRequest(),
                                                             managedObjectContext: PersistentUtils.sharedInstance.coreDataStack.mainContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
        
        UnityCommunication.sharedInstance.delegate = self
    }
    
    func contextFetchRequest() -> NSFetchRequest<Context> {
        let fetchRequest:NSFetchRequest<Context> = Context.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Context.position), ascending: true)
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
    
    func createNewContext() -> Context? {
        currentContext = Context(context: PersistentUtils.sharedInstance.coreDataStack.mainContext)
        currentContext?.position = Int16(numberOfContexts)
        return currentContext
    }
    
    func cloneContext(_ id: NSManagedObjectID) -> Context? {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = PersistentUtils.sharedInstance.coreDataStack.mainContext
        currentContext = childContext.object(with: id) as? Context
        return currentContext
    }
    
    func clearCurrentContext() {
            if let item = currentContext {
                PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(item)
                PersistentUtils.sharedInstance.coreDataStack.saveContext()
            }
            return
    }
    
    func saveCurrentContext() {
        guard let context = currentContext?.managedObjectContext else {
            return
        }
        context.perform {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Error: \(error.localizedDescription)")
                }
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
            
            //update the unity app
            self.sendContexts()
        }
    }
    
    func deleteContext(at section: Int) {
        let sections = fetchedResultController?.fetchedObjects?[section]
        PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(sections!)
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
        guard let sectionUpperBound = fetchedResultController?.fetchedObjects?.count, sectionUpperBound > section + 1 else {
            return
        }
        
        for n in section...sectionUpperBound - 1 {
            let context = fetchedResultController?.fetchedObjects?[n]
            context?.position = Int16(n)
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }
    }
    
    func deleteAllContexts() {
        if numberOfContexts <= 0 {
            return
        }
        for n in 0...numberOfContexts - 1{
            deleteContext(at: (numberOfContexts - 1) - n)
        }
    }
    
    func toggleHidde(at section: Int) {
        let sections = fetchedResultController?.fetchedObjects?[section]
        let isHidden = sections?.hidden ?? false
        sections?.hidden = !isHidden
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
        //update the unity app
        sendContexts()
    }
    
    func deactivateAllContexts() {
        let contexts = fetchedResultController?.fetchedObjects
        guard let sectionUpperBound = fetchedResultController?.fetchedObjects?.count else {
            return
        }
        
        for n in 0...sectionUpperBound - 1 {
            let context = fetchedResultController?.fetchedObjects?[n]
            context?.active = false
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }

    }
    
    func activeContext(at section: Int) {
        let contexts = fetchedResultController?.fetchedObjects
        guard let sectionUpperBound = fetchedResultController?.fetchedObjects?.count else {
            return
        }
        
        for n in 0...sectionUpperBound - 1 {
            let context = fetchedResultController?.fetchedObjects?[n]
            if (section - 1 != n) {
                context?.active = false
            } else {
                context?.active = true
            }
        }
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
    }
    
    var numberOfContexts: Int {
        if let results = fetchedResultController?.fetchedObjects {
            return results.count
        }
        return 0
    }
    
    func contextAtSection(_ section: Int) -> Context? {
        return fetchedResultController?.fetchedObjects?[section]
    }
    
    func numberOfLightPatternsForContext(_ section: Int) -> Int {
        if let lightpatterns = contextAtSection(section)?.lightpatterns {
            return lightpatterns.count
        }
        return 0
    }
    
    func lightPatternForContext(indexPath:IndexPath) -> LightPattern? {
        let sortDescriptor = [NSSortDescriptor(key: #keyPath(LightPattern.position), ascending: true)]
        if let pattern = fetchedResultController?.fetchedObjects?[indexPath.section].lightpatterns?.sortedArray(using: sortDescriptor)[indexPath.row] as? LightPattern {
            return pattern
        }
        return nil
    }
    
    func selectLightPattern(indexPath:IndexPath) {
        let sortDescriptor = [NSSortDescriptor(key: #keyPath(LightPattern.position), ascending: true)]
        if let pattern = fetchedResultController?.fetchedObjects?[indexPath.section].lightpatterns?.sortedArray(using: sortDescriptor)[indexPath.row] as? LightPattern {
            fetchedResultController?.fetchedObjects?[indexPath.section].selected = pattern
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }
    }
    
    func sendContexts() {
        if let results = fetchedResultController?.fetchedObjects {
            var myPlaceArray = [[String: Any]]()
            //let json = JSON(["context"])
            for i in 0...results.count-1 {
                
                var contextTitle = "Context "+String(i+1)
                if !results[i].hidden {
                    contextTitle = results[i].name
                }
                
                myPlaceArray.append([
                    "id" : i,
                    "name" : contextTitle,
                ])
            }
            let jsonIndexed = JSON(myPlaceArray)
            print(myPlaceArray)
            print(jsonIndexed)
            
            
            var data: Data
            
            do {
                try data = JSONSerialization.data(withJSONObject: jsonIndexed.object, options: .prettyPrinted)
            } catch let nserror as NSError {
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }

                UnityCommunication.sharedInstance.sendDataToClients(data)
            }
        
    }
    
    func newClientDidConntected() {
        sendContexts()
    }
}
