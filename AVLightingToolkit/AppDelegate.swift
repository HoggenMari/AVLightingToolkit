//
//  AppDelegate.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 07.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSFetchedResultsControllerDelegate {

    var window: UIWindow?

    var lightpatternModelController: LightPatternModelController!
    public var contextModelController: ContextModelController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //CoreDataHelper.shared.
        
        LEDController.sharedInstance
        UnityCommunication.sharedInstance
    
        //PersistentUtils.sharedInstance.coreDataStack.clearContext()

        //PersistentUtils.sharedInstance.coreDataStack.clearContext()
        lightpatternModelController = LightPatternModelController()
        lightpatternModelController.initializeFetchController(self)
        
        contextModelController = ContextModelController()
        contextModelController.initializeFetchController(self)
        
        contextModelController.deactivateAllContexts()
        
        //deleteAllData("LightPattern")
        
        //lightpatternModelController.deleteAllLightPatterns()
        //contextModelController.deleteAllContexts()
        
        if lightpatternModelController.numberOfLightPatterns <= 0 {
            PersistentUtils.sharedInstance.seedLightPattern()
        }
        
        if contextModelController.numberOfContexts <= 0 {
            PersistentUtils.sharedInstance.seedContext()
        }
        
        contextModelController.sendContexts()
        
        return true
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //
    }
}
