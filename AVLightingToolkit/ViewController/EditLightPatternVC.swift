//
//  AddLightPatternViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 29.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*enum EditLightPatternTitle {
    case newLightPattern
    case editLightPattern
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .newLightPattern: return "New Light Pattern"
        case .editLightPattern: return "Edit Light Pattern"
        }
    }
}*/

// MARK: JournalEntryDelegate
protocol LightPatternEntryDelegate {
    func didFinish(viewController: EditLightPatternVC, didSave: Bool)
}

class EditLightPatternVC: UIViewController, OverlayViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var previewImageButton: UIButton!
    @IBOutlet weak var codeTextView: UITextView!
    
    var filename: String?
    
    var delegate: LightPatternEntryDelegate?
    
    var editMode: EditMode = EditMode.new {
        didSet {
            titleLabel.text = editMode.descriptionForLightPattern
        }
    }
    
    var lightpatternViewModel: LightPatternViewModel? {
        didSet {
            configureView()
            context = lightpatternViewModel?.currentLightPattern?.managedObjectContext
        }
    }
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.95)
        previewImageButton.setIcon(icon: .googleMaterialDesign(.addAPhoto), iconSize: 60, color: .white, forState: .normal)
        configureView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        delegate?.didFinish(viewController: self, didSave: false)
        dismissOverlay()
    }

    func configureView() {
        guard let entry = lightpatternViewModel?.currentLightPattern else { return }
        
        name.text = entry.name
        if let filename = entry.imageFilename  {
            self.filename = filename
            backgroundImage.image = ImageUtils.getImageFromDocumentPath(for: filename)
        }
        if let code = entry.code {
            codeTextView.text = code
        }
        
    }
    
    func updateLightPatternEntry() {
        guard let entry = lightpatternViewModel?.currentLightPattern else { return }
        
        entry.name = name.text ?? ""
        entry.imageFilename = filename
        entry.code = codeTextView.text
        
    }
    
    @IBAction func addContext(_ sender: Any) {
        updateLightPatternEntry()
        if let titleName = lightpatternViewModel?.currentLightPattern?.name, !titleName.isEmpty {
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
