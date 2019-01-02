//
//  ViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 07.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import UIKit
import CoreData
import SwiftIcons

class ContextLightPatternListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let addViewHeight: CGFloat = 70
    let heightForFooterInSection: CGFloat = 15
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet var lightPatternTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addViewHeightConstraint: NSLayoutConstraint!
    
    var newContextEntry: Context?
    var newLightPatternEntry: LightPattern?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let headerNib = UINib.init(nibName: "ContextHeaderView", bundle: Bundle.main)
        lightPatternTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ContextHeaderView")
        
        let footerNib = UINib.init(nibName: "AddItemFooterView", bundle: Bundle.main)
        lightPatternTableView.register(footerNib, forHeaderFooterViewReuseIdentifier: "AddItemFooterView")
    
        lightPatternTableView.delegate = self
        lightPatternTableView.dataSource = self
        
        addViewHeightConstraint.constant = addViewHeight
        
        let view = Bundle.main.loadNibNamed("AddItemFooterView", owner: nil, options: nil)![0] as! AddItemFooterView
        view.translatesAutoresizingMaskIntoConstraints = false
        addView.addSubview(view)

        addView.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: addView, attribute: .trailing, multiplier: 1, constant: 0))
        addView.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: addView, attribute: .leading, multiplier: 1, constant: 0))
        addView.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: addView, attribute: .top, multiplier: 1, constant: 0))
        addView.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: addView, attribute: .bottom, multiplier: 1, constant: 0))

        view.delegate = self
    
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ContextHeaderView") as! ContextHeaderView
        

        let sections = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[section]
        
        headerView.contextTitle.text = sections?.name
        headerView.deleteButton.setIcon(icon: .googleMaterialDesign(.delete), iconSize: 40, color: .white, forState: .normal)
        headerView.delegate = self
        headerView.section = section
        headerView.tag = section
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(sender:)))
        headerView.addGestureRecognizer(tapGesture)

        guard let filename = sections?.imageFilename, let image = ImageUtils.getImageFromDocumentPath(for: filename) else {
            headerView.contextImage.image = UIImage(named: "car")
            return headerView
        }
        
        headerView.contextImage.image = image
    
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[section]
        return sections?.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?.count ?? 0
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[section].lightpatterns?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell") as! LightPatternTableViewCell
        cell.initCellItem()
        
        guard let section = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[indexPath.section] else {
            return cell
        }
        
        let sortDescriptor = [NSSortDescriptor(key: #keyPath(LightPattern.name), ascending: true)]

        guard let pattern = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[indexPath.section].lightpatterns?.sortedArray(using: sortDescriptor)[indexPath.row] as? LightPattern else {
            return cell
        }
        
        cell.radioButton.isChecked = section.selected?.isEqualTo(pattern) ?? false
        
        cell.itemLabel?.text = pattern.name
        cell.delegate = self
        
        return cell
        
    }
}

extension ContextLightPatternListVC: AddItemFooterViewDelegate, OverlayHost {
    func addContextButtonTapped() {        
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        
        newContextEntry = Context(context: PersistentUtils.sharedInstance.coreDataStack.mainContext)
        newContextEntry?.position = Int16(PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?.count ?? 0)
        
        addContextViewController?.controllerTitle = EditContextTitle.newContext
        addContextViewController?.contextEntry = newContextEntry
        addContextViewController?.context = newContextEntry?.managedObjectContext
        addContextViewController?.delegate = self
        
        lightPatternTableView.reloadData()
    }
    
    func addLightingPatternTapped() {
        let addLightPatternViewController = showOverlay(type: EditLightPatternVC.self, fromStoryboardWithName: "Main")
        
        newLightPatternEntry = LightPattern(context: PersistentUtils.sharedInstance.coreDataStack.mainContext)
        
        addLightPatternViewController?.controllerTitle = EditLightPatternTitle.newLightPattern
        addLightPatternViewController?.lightPatternEntry = newLightPatternEntry
        addLightPatternViewController?.context = newLightPatternEntry?.managedObjectContext
        addLightPatternViewController?.delegate = self
    }
    
}

extension ContextLightPatternListVC: CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath) {
        let sortDescriptor = [NSSortDescriptor(key: #keyPath(LightPattern.name), ascending: true)]

        guard let pattern = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[indexPath.section].lightpatterns?.sortedArray(using: sortDescriptor)[indexPath.row] as? LightPattern else {
            return
        }
        PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[indexPath.section].selected = pattern
        PersistentUtils.sharedInstance.coreDataStack.saveContext()
        lightPatternTableView.reloadData()
        
    }
}

extension ContextLightPatternListVC: ContextEntryDelegate, LightPatternEntryDelegate {
    
    func didFinish(viewController: EditContextVC, didSave: Bool) {
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                if newContextEntry != nil {
                PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(newContextEntry!)
                PersistentUtils.sharedInstance.coreDataStack.saveContext()
                }
                lightPatternTableView.reloadData()
                dismiss(animated: true)
                return
        }
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
            self.lightPatternTableView.reloadData()
        }
        dismiss(animated: true)
    }
    
    func didFinish(viewController: EditLightPatternVC, didSave: Bool) {
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                if newLightPatternEntry != nil {
                    PersistentUtils.sharedInstance.coreDataStack.mainContext.delete(newLightPatternEntry!)
                PersistentUtils.sharedInstance.coreDataStack.saveContext()
                }
                dismiss(animated: true)
                return
        }
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            PersistentUtils.sharedInstance.coreDataStack.saveContext()
        }
        dismiss(animated: true)
    }
}

extension ContextLightPatternListVC: ContextHeaderViewDelegate {
    func deleteButtonTapped(at section: Int) {
        PersistentUtils.sharedInstance.deleteContext(at: section)
        lightPatternTableView.reloadData()
    }
    
    @objc func sectionHeaderTapped(sender: UIGestureRecognizer) {
        
        newContextEntry = nil
        
        guard let section = sender.view?.tag, let contextEntry = PersistentUtils.sharedInstance.contextFetchedResultsController().fetchedObjects?[section] else {
            return
        }
        
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = PersistentUtils.sharedInstance.coreDataStack.mainContext
        
        let childEntry = childContext.object(with: contextEntry.objectID) as? Context
        
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        
        addContextViewController?.controllerTitle = EditContextTitle.editContext
        addContextViewController?.contextEntry = childEntry
        addContextViewController?.context = childContext
        addContextViewController?.delegate = self
        
    }
}
