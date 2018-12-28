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
    @NSManaged public var name: String?
    @NSManaged public var context: Context?

}
