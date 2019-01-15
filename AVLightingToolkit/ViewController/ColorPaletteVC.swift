//
//  ColorPaletteVC.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 15.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

class ColorPaletteVC: UIViewController {
    
    override func loadView() {
        Bundle.main.loadNibNamed("ColorPaletteVC", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
