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
    func editContextPattern(sender: UIGestureRecognizer)
}
class ContextHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var contextImage: UIImageView!
    @IBOutlet weak var contextTitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate:ContextHeaderViewDelegate!
    var section:Int!
    
    func initCellItem(for section: Int, title: String, imageFilename: String?) {
        deleteButton.setIcon(icon: .googleMaterialDesign(.delete), iconSize: 40, color: .white, forState: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(sender:)))
        addGestureRecognizer(tapGesture)
        
        contextTitle.text = title
        self.section = section
        tag = section
        
        guard let filename = imageFilename, let image = ImageUtils.getImageFromDocumentPath(for: filename) else {
            contextImage.image = UIImage(named: "car")
            return
        }
        contextImage.image = image
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.delegate?.deleteButtonTapped(at: section)
    }
    
    @objc func sectionHeaderTapped(sender: UIGestureRecognizer) {
        self.delegate?.editContextPattern(sender: sender)
    }
}
