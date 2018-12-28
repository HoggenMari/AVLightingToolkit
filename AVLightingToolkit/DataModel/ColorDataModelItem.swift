//
//  LightPatternColor.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 13.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

class LightPatternDataModelItem {
    
    var lightPatternName: String
    var lightPatternImage: UIImage?
    
    init(name: String, image: UIImage?) {
        lightPatternName = name
        lightPatternImage = image
    }
}
