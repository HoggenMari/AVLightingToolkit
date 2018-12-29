//
//  AddLightPatternViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 29.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum EditLightPatternTitle {
    case newLightPattern
    case editLightPattern
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .newLightPattern: return "New Light Pattern"
        case .editLightPattern: return "Edit Light Pattern"
        }
    }
    
}

// MARK: JournalEntryDelegate
protocol LightPatternEntryDelegate {
    func didFinish(viewController: EditLightPatternVC, didSave: Bool)
}

class EditLightPatternVC: UIViewController, OverlayViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.9,
                                      height: UIScreen.main.bounds.height * 0.6)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var previewImageButton: UIButton!
    
    var filename: String?
    
    var context: NSManagedObjectContext!
    var delegate: LightPatternEntryDelegate?
    var controllerTitle: EditLightPatternTitle = EditLightPatternTitle.newLightPattern {
        didSet {
            titleLabel.text = controllerTitle.description
        }
    }
    
    // MARK: Properties
    var lightPatternEntry: LightPattern? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.95)
        previewImageButton.setIcon(icon: .googleMaterialDesign(.addAPhoto), iconSize: 60, color: .white, forState: .normal)
        configureView()
    }

    func configureView() {
        guard let entry = lightPatternEntry else { return }
        
        name.text = entry.name
        guard let filename = entry.imageFilename else {
            return
        }
        self.filename = filename
        backgroundImage.image = ImageUtils.getImageFromDocumentPath(for: filename)
    }
    
    func updateLightPatternEntry() {
        guard let entry = lightPatternEntry else { return }
        
        entry.name = name.text
        entry.imageFilename = filename
        
    }
    
    @IBAction func addContext(_ sender: Any) {
        updateLightPatternEntry()
        if let titleName = lightPatternEntry?.name, !titleName.isEmpty {
            delegate?.didFinish(viewController: self, didSave: true)
            dismissOverlay()
        } else {
            let alert  = UIAlertController(title: "Warning", message: "Insert a name for the new context", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        delegate?.didFinish(viewController: self, didSave: false)
        dismissOverlay()
        
    }
    
    @IBAction func selectBackgroundImage(_ sender: Any) {
        openGallery()
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.backgroundImage.image = editedImage
            ImageUtils.saveImageToDocumentPath(for: info)
            filename = ImageUtils.getImageFilename(for: info)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
