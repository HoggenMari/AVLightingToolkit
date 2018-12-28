//
//  AddItemFooterView.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 14.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation

import UIKit

protocol AddItemFooterViewDelegate: class {
    func addContextButtonTapped()
    func addLightingPatternTapped()
}

class AddItemFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var addContextButton: UIButton!
    @IBOutlet weak var addLightPatternButton: UIButton!
    
    public weak var delegate: AddItemFooterViewDelegate?
    
    @IBAction func addContextButtonTapped(_ sender: Any) {
        delegate?.addContextButtonTapped()
    }
    
    @IBAction func addLightPatternButtonTapped(_ sender: Any) {
        delegate?.addLightingPatternTapped()
    }
    
}
