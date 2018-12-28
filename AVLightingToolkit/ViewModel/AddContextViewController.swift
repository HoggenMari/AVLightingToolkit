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

enum AddContextViewControllerTitle {
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
    func didFinish(viewController: AddContextViewController, didSave: Bool)
}

class AddContextViewController: UIViewController, OverlayViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.9,
                                      height: UIScreen.main.bounds.height * 0.6)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    
    var managedObjectContext: NSManagedObjectContext!

    var filename: String?
    
    // MARK: Properties
    var contextEntry: Context? {
        didSet {
            updateContextEntry()
        }
    }
    var context: NSManagedObjectContext!
    var delegate: ContextEntryDelegate?
    var controllerTitle: AddContextViewControllerTitle = AddContextViewControllerTitle.newContext {
        
        didSet {
            titleLabel.text = controllerTitle.description
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AVLightingToolkit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.95)
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
        print("selectBackgroundImageTapped")
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

