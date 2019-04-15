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
    func toggleHidden(at section:Int)
}
class ContextHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var contextImage: UIImageView!
    @IBOutlet weak var contextTitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    var gradient = CAGradientLayer()
    
    var delegate:ContextHeaderViewDelegate!
    var section:Int!
    
    func initCellItem(for section: Int, title: String, imageFilename: String?, isActive: Bool) {
        deleteButton.setIcon(icon: .googleMaterialDesign(.delete), iconSize: 40, color: .white, forState: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(sender:)))
        addGestureRecognizer(tapGesture)
        
        contextTitle.text = title
        self.section = section
        tag = section
        
        var image: UIImage!
        if let filename = imageFilename, let img = ImageUtils.getImageFromDocumentPath(for: filename) {
            image = img
        } else if let filename = imageFilename, let img = UIImage(named: filename) {
            image = img
        } else {
            image = UIImage(named: "car")
        }
        
        if(!isActive){
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        } else {
        gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        }
        gradient.locations = [0.0, 0.75, 1.25]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.0)
        
        gradientView.layer.insertSublayer(gradient, at: 0)
        
        contextImage.image = image
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longPressRecognizer.minimumPressDuration = 3
        addGestureRecognizer(longPressRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientView != nil {
            gradient.frame = gradientView.bounds
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.delegate?.deleteButtonTapped(at: section)
    }
    
    @objc func sectionHeaderTapped(sender: UIGestureRecognizer) {
        self.delegate?.editContextPattern(sender: sender)
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            print("test")
            print(section)
            self.delegate?.toggleHidden(at: section)
        }
    }
    
    
}
