//
//  ViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 07.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import UIKit
import CoreData
import EFColorPicker

class ContextLightPatternListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let heightForFooterInSection: CGFloat = 15
        
    @IBOutlet var lightPatternTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var addContextBtn: UIButton!
    @IBOutlet weak var addLightPatternBtn: UIButton!
    
    var newContextEntry: Context?
    var newLightPatternEntry: LightPattern?
    
    var contextViewModel: ContextViewModel!
    var lightpatternViewModel: LightPatternViewModel!
    
    var selectedColor: UIColor!
    var selectedIndexPath: IndexPath!
    var selectedColorIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let headerNib = UINib.init(nibName: "ContextHeaderView", bundle: Bundle.main)
        lightPatternTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ContextHeaderView")
        
        lightPatternTableView.delegate = self
        lightPatternTableView.dataSource = self
        
        contextViewModel = ContextViewModel()
        contextViewModel.initializeFetchController(self)
        
        lightpatternViewModel = LightPatternViewModel()
        lightpatternViewModel.initializeFetchController(self)
        
        addContextBtn.setIcon(prefixText: "", prefixTextColor: .gray, icon: .googleMaterialDesign(.details), iconColor: .gray, postfixText: "Add Context", postfixTextColor: .gray, backgroundColor: .clear, forState: .normal, textSize: 18, iconSize: 18)
        addContextBtn.addTarget(self, action: #selector(addContextButtonTapped), for: .touchUpInside)
        
        addLightPatternBtn.setIcon(prefixText: "", prefixTextColor: .gray, icon: .googleMaterialDesign(.blurOn), iconColor: .gray, postfixText: "Add Light Pattern", postfixTextColor: .gray, backgroundColor: .clear, forState: .normal, textSize: 18, iconSize: 18)
        addLightPatternBtn.addTarget(self, action: #selector(addLightingPatternTapped), for: .touchUpInside)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContextHeaderView") as! ContextHeaderView

        if let context = contextViewModel.contextAtSection(section) {
            headerView.initCellItem(for: section, title: context.name, imageFilename: context.imageFilename)
            headerView.delegate = self
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contextViewModel.numberOfContexts
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextViewModel.numberOfLightPatternsForContext(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell") as! LightPatternTableViewCell
        cell.delegate = self
        
        if let context = contextViewModel.contextAtSection(indexPath.section), let pattern = contextViewModel.lightPatternForContext(indexPath: indexPath) {
            let selected = context.selected?.isEqualTo(pattern) ?? false
            cell.initCellItem(for: pattern.name, imageFileName: pattern.imageFilename, color: [pattern.color1, pattern.color2, pattern.color3], selected: selected)
        }
        
        return cell
    }
    
}

extension ContextLightPatternListVC: OverlayHost {
    @objc func addContextButtonTapped() {
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        _ = contextViewModel.createNewContext()
        addContextViewController?.lightpatternViewModel = lightpatternViewModel
        addContextViewController?.contextViewModel = contextViewModel
        addContextViewController?.editMode = EditMode.new
        addContextViewController?.delegate = self
    }
    
    @objc func addLightingPatternTapped() {
        let addLightPatternViewController = showOverlay(type: EditLightPatternVC.self, fromStoryboardWithName: "Main")
        _ = lightpatternViewModel.createNewLightPattern()
        addLightPatternViewController?.lightpatternViewModel = lightpatternViewModel
        addLightPatternViewController?.editMode = EditMode.new
        addLightPatternViewController?.delegate = self
    }
    
}

extension ContextLightPatternListVC: CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath) {
        contextViewModel.selectLightPattern(indexPath: indexPath)
    }
    
    func colorTapped(_ sender: UIButton, indexPath: IndexPath, colorIndex: Int) {
        print(indexPath.row)
        print(colorIndex)
        colorPicker(sender, indexPath: indexPath, colorIndex: colorIndex)
    }
}

extension ContextLightPatternListVC: ContextEntryDelegate, LightPatternEntryDelegate {
    
    func didFinish(viewController: EditContextVC, didSave: Bool) {
        if didSave {
            contextViewModel.saveCurrentContext()
        } else {
            contextViewModel.clearCurrentContext()
            lightPatternTableView.reloadData()
        }
        dismiss(animated: true)
    }
    
    func didFinish(viewController: EditLightPatternVC, didSave: Bool) {
        if didSave {
            lightpatternViewModel.saveCurrentLightPattern()
        } else {
            lightpatternViewModel.clearCurrentLightPattern()
        }
        dismiss(animated: true)
    }
}

extension ContextLightPatternListVC: ContextHeaderViewDelegate {
    func deleteButtonTapped(at section: Int) {
        contextViewModel.deleteContext(at: section)
    }
    
    func editContextPattern(sender: UIGestureRecognizer) {
        guard let section = sender.view?.tag else {
            return
        }
        _ = contextViewModel.cloneContext((contextViewModel.contextAtSection(section)?.objectID)!)
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        addContextViewController?.lightpatternViewModel = lightpatternViewModel
        addContextViewController?.contextViewModel = contextViewModel
        addContextViewController?.editMode = EditMode.edit
        addContextViewController?.delegate = self
    }
}

extension ContextLightPatternListVC: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        lightPatternTableView.reloadData()
        print("changes")
    }
    
}


extension ContextLightPatternListVC: UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
            print("didchangecolor")
            selectedColor = color
        
            guard let entry = lightpatternViewModel?.lightPattern(at: selectedIndexPath) else { return }
            if selectedColorIndex == 0 {
                entry.color1 = selectedColor.encode()
                LEDController.sharedInstance.setColor1(selectedColor)
            } else if selectedColorIndex == 1 {
                entry.color2 = selectedColor.encode()
                LEDController.sharedInstance.setColor2(selectedColor)
            } else if selectedColorIndex == 2 {
                entry.color3 = selectedColor.encode()
            }
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        
    }
        
    func colorPicker(_ sender: UIButton, indexPath: IndexPath, colorIndex: Int) {
            selectedIndexPath = indexPath
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
