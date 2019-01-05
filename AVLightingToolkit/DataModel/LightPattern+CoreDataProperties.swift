//
//  LightPattern+CoreDataProperties.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 20.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//
//

import Foundation
import CoreData


extension LightPattern {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LightPattern> {
        return NSFetchRequest<LightPattern>(entityName: "LightPattern")
    }

    @NSManaged public var imageFilename: String?
    @NSManaged public var name: String
    @NSManaged public var code: String?
    @NSManaged public var context: Context?
    
    public func isEqualTo(_ object: Any?) -> Bool {
        return
            name == (object as? LightPattern)?.name
    }

}

// MARK: Generated accessors for lightpatterns
extension LightPattern {
    
    @objc(addContextObject:)
    @NSManaged public func addContextObject(_ value: Context)
    
    @objc(removeContextObject:)
    @NSManaged public func removeContextObject(_ value: Context)
    
    @objc(addContexts:)
    @NSManaged public func addContextObject(_ values: NSSet)
    
    @objc(removeContexts:)
    @NSManaged public func removeContextObject(_ values: NSSet)
    
}


