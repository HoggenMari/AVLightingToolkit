//
//  MessageViewController.swift
//  OverlayViewController
//
//  Created by Andrey Gordeev on 4/17/17.
//  Copyright © 2017 Andrey Gordeev (andrew8712@gmail.com). All rights reserved.
//

import UIKit
import Photos
import CoreData
import SwiftIcons

enum EditContextTitle {
    case newContext
    case editContext
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .newContext: return "New Context"
        case .editContext: return "Edit Context"
        }
    }
    
}

// MARK: JournalEntryDelegate
protocol ContextEntryDelegate {
    func didFinish(viewController: EditContextVC, didSave: Bool)
}

class EditContextVC: UIViewController, OverlayViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /*let overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.9,
                                      height: UIScreen.main.bounds.height * 0.6)*/
    let heightForRow: CGFloat = 30
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var backgroundImageButton: UIButton!
    @IBOutlet weak var lightPatternTableView: UITableView!
    
    var filename: String?
    
    // MARK: Properties
    var contextEntry: Context? {
        didSet {
            configureView()
        }
    }
    
    var context: NSManagedObjectContext!
    var delegate: ContextEntryDelegate?
    var controllerTitle: EditContextTitle = EditContextTitle.newContext {
        
        didSet {
            titleLabel.text = controllerTitle.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.95)
        backgroundImageButton.setIcon(icon: .googleMaterialDesign(.addAPhoto), iconSize: 60, color: .white, forState: .normal)
        
        lightPatternTableView.delegate = self
        lightPatternTableView.dataSource = self
        
        configureView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        delegate?.didFinish(viewController: self, didSave: false)
        dismissOverlay()
    }
    
    func configureView() {
        guard let entry = contextEntry else { return }

        name.text = entry.name
        guard let filename = entry.imageFilename else {
            return
        }
        self.filename = filename
        backgroundImage.image = ImageUtils.getImageFromDocumentPath(for: filename)
    }
    
    func updateContextEntry() {
        guard let entry = contextEntry else { return }
        
        entry.name = name.text
        entry.imageFilename = filename
        
    }

    @IBAction func addContext(_ sender: Any) {
        updateContextEntry()
        if let titleName = contextEntry?.name, !titleName.isEmpty {
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

extension EditContextVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersistentUtils.sharedInstance.lightPatternFetchedResultsController().fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddLightPatternToContextTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "lightpattern") as! AddLightPatternToContextTableViewCell
        cell.initCell(at: indexPath.row)
        
        let pattern = PersistentUtils.sharedInstance.lightPatternFetchedResultsController().object(at: indexPath)
        cell.itemLabel?.text = pattern.name
        cell.delegate = self
        
        if let patternLength = contextEntry?.lightpatterns?.count, patternLength > 0 {
            for n in 0...patternLength-1 {
                let p = contextEntry?.lightpatterns?.allObjects[n] as! LightPattern
                if p.isEqualTo(pattern) {
                    cell.button?.isChecked = true
                    return cell
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
}

extension EditContextVC: LightPatternSelectedDelegate {
    func didToggleLightPatternCheckbox(patternWith index: Int, checked: Bool) {
        print(String(index)+""+String(checked))
        
        guard let pattern = PersistentUtils.sharedInstance.lightPatternFetchedResultsController().fetchedObjects?[index] else {
            return
        }
        
        if checked {
            contextEntry?.addToLightpatterns(pattern)
        } else {
            if let patternLength = contextEntry?.lightpatterns?.count, patternLength > 0 {
                for n in 0...patternLength-1 {
                    let p = contextEntry?.lightpatterns?.allObjects[n] as! LightPattern
                    if p.isEqualTo(pattern) {
                        contextEntry?.removeFromLightpatterns(p)
                        return
                    }
                }
            }
        }
    }
}
