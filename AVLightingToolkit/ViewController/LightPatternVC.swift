//
//  LightPatternVC.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 03.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LightPatternVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var lightPattern: UIBarButtonItem!
    
    var viewModel: LightPatternViewModel? {
        didSet {
            viewModel?.initializeFetchController(self)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        table.delegate = self
        table.dataSource = self
        
        lightPattern.setIcon(prefixText: "", icon: .googleMaterialDesign(.blurOn), iconColor: .gray, postfixText: "Add Light Pattern", postfixTextColor: .darkGray, cgRect: CGRect(x: 0, y: 0, width: 0, height: 0), size: 18, target: self, action: #selector(buttonAction(sender:)))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfLightPatterns ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell:AllLightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "lightpatterncell") as! AllLightPatternTableViewCell
        
        if let lightpattern = viewModel?.lightPattern(at: indexPath) {
            cell.initCellItem(for: lightpattern.name, imageFileName: lightpattern.imageFilename, selected: false)
        }*/
        
        let cell:EditLightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "editLightPatternCell") as! EditLightPatternTableViewCell
        
        cell.delegate = self
        
        if let lightpattern = viewModel?.lightPattern(at: indexPath) {
            cell.initCellItem(for: indexPath.row, title: lightpattern.name, imageFileName: lightpattern.imageFilename, selected: false)
        }
        
        return cell
    }
    
    @objc func buttonAction(sender: UIBarButtonItem) {
        print("test")
    }
    
    
}

extension LightPatternVC: LightPatternEntryDelegate, EditLightPatternDelegate, OverlayHost {
    
    func edit(_ row: Int) {
        if let vm = viewModel {
            _ = vm.cloneLightPattern((vm.lightPattern(for: row)?.objectID)!)
            let addContextViewController = showOverlay(type: EditLightPatternVC.self, fromStoryboardWithName: "Main")
            addContextViewController?.lightpatternViewModel = vm
            addContextViewController?.editMode = EditMode.edit
            addContextViewController?.delegate = self
        }
    }
    
    func delete(_ row: Int) {
        viewModel?.deleteLightPattern(at: row)
    }
    
    func didFinish(viewController: EditLightPatternVC, didSave: Bool) {
        if didSave {
            viewModel?.saveCurrentLightPattern()
        } else {
            viewModel?.clearCurrentLightPattern()
        }
        dismiss(animated: true)
    }
}

extension LightPatternVC: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.reloadData()
        print("changes")
    }
    
}
