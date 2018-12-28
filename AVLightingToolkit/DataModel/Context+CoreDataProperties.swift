//
//  Context+CoreDataProperties.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 20.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//
//

import Foundation
import CoreData


extension Context {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Context> {
        return NSFetchRequest<Context>(entityName: "Context")
    }

    @NSManaged public var imageFilename: String?
    @NSManaged public var name: String?
    @NSManaged public var position: Int16
    @NSManaged public var lightpatterns: NSSet?

}

// MARK: Generated accessors for lightpatterns
extension Context {

    @objc(addLightpatternsObject:)
    @NSManaged public func addToLightpatterns(_ value: LightPattern)

    @objc(removeLightpatternsObject:)
    @NSManaged public func removeFromLightpatterns(_ value: LightPattern)

    @objc(addLightpatterns:)
    @NSManaged public func addToLightpatterns(_ values: NSSet)

    @objc(removeLightpatterns:)
    @NSManaged public func removeFromLightpatterns(_ values: NSSet)

}
