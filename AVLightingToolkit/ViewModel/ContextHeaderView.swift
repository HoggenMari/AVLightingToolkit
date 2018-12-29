//
//  ContextHeaderView.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 13.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

protocol ContextHeaderViewDelegate{
    func deleteButtonTapped(at section:Int)
}
class ContextHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var contextImage: UIImageView!
    @IBOutlet weak var contextTitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate:ContextHeaderViewDelegate!
    var section:Int!
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.delegate?.deleteButtonTapped(at: section)
    }
    
}
