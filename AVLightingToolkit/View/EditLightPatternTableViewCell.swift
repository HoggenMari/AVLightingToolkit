//
//  EditLightPatternTableViewCell.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 05.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

protocol EditLightPatternDelegate {
    func edit(_ row: Int)
    func delete(_ row: Int)
}

class EditLightPatternTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: EditLightPatternDelegate?
    var row: Int!
    
    func initCellItem(for row: Int, title: String, imageFileName: String?, selected: Bool) {
        self.row = row
        itemLabel.text = title
        
        if let filename = imageFileName, let image = ImageUtils.getImageFromDocumentPath(for: filename) {
            itemImage.image = image
        } else if let filename = imageFileName, let image = UIImage(named: filename) {
            itemImage.image = image
        } else {
            itemImage.image = UIImage(named: "brightness_pattern")
        }
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemImageTapped))
        singleTap.numberOfTapsRequired = 1;
        itemImage.isUserInteractionEnabled = true
        itemImage?.addGestureRecognizer(singleTap)
        
        editBtn.setIcon(icon: .googleMaterialDesign(.edit), iconColor: .gray, title: "", forState: .normal)
        deleteBtn.setIcon(icon: .googleMaterialDesign(.delete), iconColor: .gray, title: "", forState: .normal)
        
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        itemTapped()
    }
    
    @objc func itemImageTapped(_ imageItem: UIImage) {
        itemTapped()
    }
    
    func itemTapped() {
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        delegate?.edit(row)
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        delegate?.delete(row)
    }
    
}
