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
import EFColorPicker

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
    
    @IBOutlet weak var colorView: UIView!
    
    var customColorView: ColorPaletteEditView!
    var selectedColor: [Data?] = [ nil, nil, nil ]
    var selectedColorIndex: Int!
    
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
        
        if let customView = Bundle.main.loadNibNamed("ColorPaletteEditView", owner: self, options: nil)?.first as? ColorPaletteEditView {
            customColorView = customView
            colorView.addSubview(customColorView)
            
            customColorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":customColorView]))
            colorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":customColorView]))
            
            customColorView.delegate = self
        }

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
        selectedColor[0] = entry.color1
        selectedColor[1] = entry.color2
        selectedColor[2] = entry.color3

        customColorView.initView(with: selectedColor)
        
    }
    
    func updateLightPatternEntry() {
        guard let entry = lightpatternViewModel?.currentLightPattern else { return }
        
        entry.name = name.text ?? ""
        entry.imageFilename = filename
        entry.code = codeTextView.text
        entry.color1 = selectedColor[0]
        entry.color2 = selectedColor[1]
        entry.color3 = selectedColor[2]
        
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
        if editMode == .edit {
            lightpatternViewModel?.currentLightPattern = nil
        }
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

extension EditLightPatternVC: ColorPaletteDelegate {
    func didTappedColor(_ sender: UIButton, colorIndex: Int) {
        colorPicker(sender, colorIndex: colorIndex)
    }
}

extension EditLightPatternVC: UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        print("didchangecolor")
        selectedColor[selectedColorIndex] = color.encode()
        
        customColorView.setColor(for: selectedColorIndex, color: color)
        
    }
    
    func colorPicker(_ sender: UIButton, colorIndex: Int) {
        selectedColorIndex = colorIndex
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = UIColor.white
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.delegate = self
        navCtrl.popoverPresentationController?.sourceView = sender
        navCtrl.popoverPresentationController?.sourceRect = sender.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = self.view.backgroundColor ?? UIColor.white
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItem.Style.done,
                target: self,
                action: #selector(ef_dismissViewController(sender:))
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        self.present(navCtrl, animated: true, completion: nil)
    }
    
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            [weak self] in
            if let _ = self {
                // TODO: You can do something here when EFColorPicker close.
                print("EFColorPicker closed.")
            }
        }
    }
}
