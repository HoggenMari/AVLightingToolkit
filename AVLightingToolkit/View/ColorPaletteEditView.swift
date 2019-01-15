//
//  ColorPaletteView.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 15.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit
import EFColorPicker

class ColorPaletteEditView: UIStackView  {
    
    var delegate: ColorPaletteDelegate! = nil
    
    @IBOutlet weak var color1: UIButton!
    @IBOutlet weak var color2: UIButton!
    @IBOutlet weak var color3: UIButton!
    @IBOutlet weak var color1text: UILabel!
    @IBOutlet weak var color2text: UILabel!
    @IBOutlet weak var color3text: UILabel!
    
    var colorValue1: UIColor!
    
    func initView(with color: [Data?]) {
        
        if color.count >= 1, let c1 = color[0]  {
            color1.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.color(withData: c1), backgroundColor: UIColor.clear, forState: .normal)
        } else {
            color1.alpha = 0.3
            color1text.alpha = 0.3
            color1.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.black, backgroundColor: UIColor.clear, forState: .normal)
        }
         
         if color.count >= 2, let c2 = color[1] {
            color2.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.color(withData: c2), backgroundColor: UIColor.clear, forState: .normal)
         } else {
            color2.alpha = 0.3
            color2text.alpha = 0.3
            color2.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.black, backgroundColor: UIColor.clear, forState: .normal)
        }
         
         if color.count >= 3, let c3 = color[2] {
            color3.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.color(withData: c3), backgroundColor: UIColor.clear, forState: .normal)
         } else {
            color3.alpha = 0.3
            color3text.alpha = 0.3
            color3.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: UIColor.black, backgroundColor: UIColor.clear, forState: .normal)
        }
        
    }
    @IBAction func color1Tapped(_ sender: UIButton) {
        delegate?.didTappedColor(sender, colorIndex: 0)
    }
    
    @IBAction func color2Tapped(_ sender: UIButton) {
        delegate?.didTappedColor(sender, colorIndex: 1)
    }
    
    @IBAction func color3Tapped(_ sender: UIButton) {
        delegate?.didTappedColor(sender, colorIndex: 2)
    }
    
    func setColor(for colorIndex: Int, color: UIColor) {
        if colorIndex == 0 {
            color1.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: color, backgroundColor: UIColor.clear, forState: .normal)
        } else if colorIndex == 1 {
            color2.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: color, backgroundColor: UIColor.clear, forState: .normal)
        } else if colorIndex == 2 {
            color3.setIcon(icon: .googleMaterialDesign(.brightness1), iconSize: 30, color: color, backgroundColor: UIColor.clear, forState: .normal)
        }
    }
    
}
