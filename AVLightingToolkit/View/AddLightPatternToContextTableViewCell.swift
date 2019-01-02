//
//  AddLightPatternToContextTableViewCell.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 29.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

protocol LightPatternSelectedDelegate {
    
    func didToggleLightPatternCheckbox(patternWith index: Int, checked: Bool)
}

class AddLightPatternToContextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var button: CheckBox!
    var delegate: LightPatternSelectedDelegate? = nil
    var index = 0
    
    func initCell(at index: Int) {
        self.index = index
        button.addTarget(self, action: #selector(AddLightPatternToContextTableViewCell.radioButtonTapped), for: .touchUpInside)

    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        delegate?.didToggleLightPatternCheckbox(patternWith: index, checked: button.isChecked)
    }
    
}

class CheckBox: UIButton {
    
    // Bool property
    public var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setIcon(icon: .emoji(.checkboxChecked), iconSize: 20, color: .black, forState: .normal)
            } else {
                self.setIcon(icon: .emoji(.checkboxUnchecked), iconSize: 20, color: .black, forState: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}

