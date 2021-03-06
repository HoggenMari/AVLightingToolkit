//
//  ViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 07.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import UIKit
import CoreData
//import EFColorPicker

class ContextLightPatternListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UnityContextDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let heightForFooterInSection: CGFloat = 15
        
    @IBOutlet var lightPatternTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var addContextBtn: UIButton!
    @IBOutlet weak var addLightPatternBtn: UIButton!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    var newContextEntry: Context?
    var newLightPatternEntry: LightPattern?
    
    var contextViewModel: ContextModelController!
    var lightpatternViewModel: LightPatternModelController!
    
    var selectedColor: UIColor!
    var selectedIndexPath: IndexPath!
    var selectedColorIndex: Int!
    
    var editMode = true
    var tangibleMode = true
    var brightness = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let defaults = UserDefaults.standard
        editMode = defaults.bool(forKey: "editMode")
        tangibleMode = defaults.bool(forKey: "tangibleMode")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.editModeChanged), name: NSNotification.Name(rawValue: "editModeChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tangibleModeChanged), name: NSNotification.Name(rawValue: "tangibleModeChanged"), object: nil)
        
        let headerNib = UINib.init(nibName: "ContextHeaderView", bundle: Bundle.main)
        lightPatternTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ContextHeaderView")
        
        lightPatternTableView.delegate = self
        lightPatternTableView.dataSource = self
        
        contextViewModel = appDelegate.contextModelController
        contextViewModel.initializeFetchController(self)
        
        lightpatternViewModel = appDelegate.lightpatternModelController //LightPatternModelController()
        lightpatternViewModel.initializeFetchController(self)
        
        UnityCommunication.sharedInstance.contextDelegate = self
        
        displayToolbar(editMode)
        changeHeaderViews(editMode)

    }
    
    func displayToolbar(_ editMode: Bool) {
        if (editMode) {
            toolbar.isHidden = false
            addContextBtn.setIcon(prefixText: "", prefixTextColor: .gray, icon: .googleMaterialDesign(.details), iconColor: .gray, postfixText: "Add Context", postfixTextColor: .gray, backgroundColor: .clear, forState: .normal, textSize: 18, iconSize: 18)
            addContextBtn.addTarget(self, action: #selector(addContextButtonTapped), for: .touchUpInside)
            
            addLightPatternBtn.setIcon(prefixText: "", prefixTextColor: .gray, icon: .googleMaterialDesign(.blurOn), iconColor: .gray, postfixText: "Add Light Pattern", postfixTextColor: .gray, backgroundColor: .clear, forState: .normal, textSize: 18, iconSize: 18)
            addLightPatternBtn.addTarget(self, action: #selector(addLightingPatternTapped), for: .touchUpInside)
        } else {
            toolbar.isHidden = true
            let defaults = UserDefaults.standard
            let brightness = defaults.double(forKey: "brightness")
            brightnessSlider.value = Float(brightness)
        }
    }
    
    func changeHeaderViews(_ editMode: Bool) {
        //var subviews = [UIView]()
        let sectionCount = lightPatternTableView.numberOfSections
        
        /// loop through available sections
        for section in 0..<sectionCount {
            
            /// get each section headers
            let sectionHeader = self.tableView(lightPatternTableView, viewForHeaderInSection: section) as! ContextHeaderView
            
            sectionHeader.setEditMode(editMode)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContextHeaderView") as! ContextHeaderView

        if let context = contextViewModel.contextAtSection(section) {
            if !context.hidden {
                headerView.initCellItem(for: section, title: context.name, imageFilename: context.imageFilename, isActive: context.active)
            } else {
                headerView.initCellItem(for: section, title: "Context " + String(section+1), imageFilename: nil, isActive: context.active)
            }
            
            if context.active {
                headerView.layer.cornerRadius = 10.0
                headerView.layer.shadowColor = UIColor.black.cgColor
                headerView.layer.shadowOffset = .zero
                headerView.layer.shadowOpacity = 0.6
                headerView.layer.shadowRadius = 10.0
                headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
                headerView.layer.shouldRasterize = true
            } else {
                headerView.layer.shadowOpacity = 0.0
            }
            
            headerView.delegate = self
            headerView.setEditMode(editMode)

        }
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < numberOfSections(in: tableView) - 1 {
            return heightForFooterInSection
        } else {
            return 0
        }
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
            if context.hidden {
                cell.initCellItem(for: "Visualisation " + String(indexPath.row+1), imageFileName: pattern.imageFilename, color: [pattern.color1, pattern.color2, pattern.color3], selected: selected)
            } else {
                cell.initCellItem(for: pattern.name, imageFileName: pattern.imageFilename, color: [pattern.color1, pattern.color2, pattern.color3], selected: selected)
            }
            
            if (selected && context.active) {
                animateCell(cell)
                print(pattern.position)
                if let code = pattern.code {
                    LEDController.sharedInstance.play(code)
                }
                if let color1 = contextViewModel.lightPatternForContext(indexPath: indexPath)?.color1 {
                    LEDController.sharedInstance.setColor1(UIColor.color(withData: color1))
                }
                
                if let color2 = contextViewModel.lightPatternForContext(indexPath: indexPath)?.color2 {
                    LEDController.sharedInstance.setColor2(UIColor.color(withData: color2))
                }
            } else {
                cell.contentView.backgroundColor = UIColor.clear
            }
        }
        
        return cell
    }
    
    func contextActivated(_ id: Int) {
        print("context activated")
        print(id)
        contextViewModel.activeContext(at: id)

        DispatchQueue.main.async {
            if id > 0 {
                let indexPath = IndexPath(row: 0, section: id-1)
                self.lightPatternTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    @objc func editModeChanged(notification: NSNotification) {
        //Insert code here
        editMode = !editMode
        displayToolbar(editMode)
        changeHeaderViews(editMode)
        //self.view.setNeedsDisplay()
    }
    
    @objc func tangibleModeChanged(notification: NSNotification) {
        tangibleMode = !tangibleMode
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        brightness = Double((sender as! UISlider).value)
        let defaults = UserDefaults.standard
        defaults.set(brightness, forKey: "brightness")
        LEDController.sharedInstance.setBrightness(brightness)
    }
    
    fileprivate var color1 = UIColor.clear
    fileprivate var color2 = UIColor(red: 0.1, green: 0.9, blue: 0.25, alpha: 0.5)
    fileprivate func animateCell(_ cell: UITableViewCell) {
        
        cell.contentView.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            cell.contentView.backgroundColor = self.color2
        }, completion: nil)
        
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
        
        if (!tangibleMode) {
            print("activate light pattern")
            print(indexPath.section)
            contextViewModel.activateContext(at: indexPath.section+1)
        }

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
    func toggleHidden(at section: Int) {
        contextViewModel.toggleHidde(at: section)
    }
    
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
        //print("changes")
    }
    
}


extension ContextLightPatternListVC: UIPopoverPresentationControllerDelegate, EFColorSelectionViewControllerDelegate {
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
            //print("didchangecolor")
            selectedColor = color
        
            guard let entry = contextViewModel.lightPatternForContext(indexPath: selectedIndexPath) else { return }
            if selectedColorIndex == 0 {
                entry.color1 = selectedColor.encode()
                LEDController.sharedInstance.setColor1(selectedColor)
            } else if selectedColorIndex == 1 {
                entry.color2 = selectedColor.encode()
                LEDController.sharedInstance.setColor2(selectedColor)
            } else if selectedColorIndex == 2 {
                entry.color3 = selectedColor.encode()
            }
        
    }
        
    func colorPicker(_ sender: UIButton, indexPath: IndexPath, colorIndex: Int) {
            selectedIndexPath = indexPath
            selectedColorIndex = colorIndex
        guard let entry = contextViewModel.lightPatternForContext(indexPath: selectedIndexPath) else { return }//lightpatternViewModel?.lightPattern(at: selectedIndexPath) else { return }
            var selectedColor: UIColor!
            if selectedColorIndex == 0 {
                selectedColor = UIColor.color(withData: entry.color1!)
            } else if selectedColorIndex == 1 {
                selectedColor = UIColor.color(withData: entry.color2!)
            } else if selectedColorIndex == 2 {
                selectedColor = UIColor.color(withData: entry.color3!)
            }
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
            colorSelectionController.color = selectedColor
            colorSelectionController.set()
            
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
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        return true
    }
}

extension EFColorSelectionViewController {
    
    func set(){
    //self.colorSelectionView().setSelectedIndex(
    //index: EFSelectedColorView(rawValue: 1) ?? EFSelectedColorView.HSB,
    //animated: true
    //)
    }
}
