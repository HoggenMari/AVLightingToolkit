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
    
    lazy var coreDataStack = CoreDataStack(modelName: "AVLightingToolkit")
    var contextFetchedRC: NSFetchedResultsController<Context> = NSFetchedResultsController()
    var lightPatternFetchedRC: NSFetchedResultsController<LightPattern> = NSFetchedResultsController()

    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet var lightPatternTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addViewHeightConstraint: NSLayoutConstraint!
    
    var newContextEntry: Context?
    var newLightPatternEntry: LightPattern?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        contextFetchedRC = contextFetchedResultsController()
        lightPatternFetchedRC = lightPatternFetchedResultsController()
        
        let headerNib = UINib.init(nibName: "ContextHeaderView", bundle: Bundle.main)
        lightPatternTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ContextHeaderView")
        
        let footerNib = UINib.init(nibName: "AddItemFooterView", bundle: Bundle.main)
        lightPatternTableView.register(footerNib, forHeaderFooterViewReuseIdentifier: "AddItemFooterView")
    
        lightPatternTableView.delegate = self
        lightPatternTableView.dataSource = self
        
        addViewHeightConstraint.constant = 70
        
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
        

        let sections = contextFetchedRC.fetchedObjects?[section]
        
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

        return 15
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = contextFetchedRC.fetchedObjects?[section]
        return sections?.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = contextFetchedRC.fetchedObjects?.count ?? 0
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextFetchedRC.fetchedObjects?[section].lightpatterns?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell") as! LightPatternTableViewCell
        
        let pattern = contextFetchedRC.fetchedObjects?[indexPath.section].lightpatterns?.allObjects[indexPath.row] as! LightPattern
        
        cell.itemLabel?.text = pattern.name
        
        return cell
        
    }
}

extension ContextLightPatternListVC: AddItemFooterViewDelegate, OverlayHost {
    func addContextButtonTapped() {
        print("addContextButtonTapped")
        
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        
        newContextEntry = Context(context: coreDataStack.mainContext)
        newContextEntry?.position = Int16(contextFetchedRC.fetchedObjects?.count ?? 0)
        
        addContextViewController?.controllerTitle = EditContextTitle.newContext
        addContextViewController?.contextEntry = newContextEntry
        addContextViewController?.context = newContextEntry?.managedObjectContext
        addContextViewController?.delegate = self
    }
    
    func addLightingPatternTapped() {
        print("addLightPatternButtonTapped")
        
        let addLightPatternViewController = showOverlay(type: EditLightPatternVC.self, fromStoryboardWithName: "Main")
        
        newLightPatternEntry = LightPattern(context: coreDataStack.mainContext)
        
        addLightPatternViewController?.controllerTitle = EditLightPatternTitle.newLightPattern
        addLightPatternViewController?.lightPatternEntry = newLightPatternEntry
        addLightPatternViewController?.context = newLightPatternEntry?.managedObjectContext
        addLightPatternViewController?.delegate = self
    }
    
}

extension ContextLightPatternListVC: CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath) {
        //do nothing
    }
}

extension ContextLightPatternListVC: ContextEntryDelegate, LightPatternEntryDelegate {
    
    func didFinish(viewController: EditContextVC, didSave: Bool) {
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                if newContextEntry != nil {
                    coreDataStack.mainContext.delete(newContextEntry!)
                    coreDataStack.saveContext()
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
            self.coreDataStack.saveContext()
        }
        dismiss(animated: true)
    }
    
    func didFinish(viewController: EditLightPatternVC, didSave: Bool) {
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                if newLightPatternEntry != nil {
                    coreDataStack.mainContext.delete(newLightPatternEntry!)
                    coreDataStack.saveContext()
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
            self.coreDataStack.saveContext()
        }
        dismiss(animated: true)
    }
}

extension ContextLightPatternListVC: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        lightPatternTableView.reloadData()
    }
    
}

extension ContextLightPatternListVC: ContextHeaderViewDelegate {
    func deleteButtonTapped(at section: Int) {
        deleteContext(at: section)
    }
    
    @objc func sectionHeaderTapped(sender: UIGestureRecognizer) {
        
        guard let section = sender.view?.tag, let contextEntry = contextFetchedRC.fetchedObjects?[section] else {
            return
        }
        
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = coreDataStack.mainContext
        
        let childEntry = childContext.object(with: contextEntry.objectID) as? Context
        
        let addContextViewController = showOverlay(type: EditContextVC.self, fromStoryboardWithName: "Main")
        
        addContextViewController?.controllerTitle = EditContextTitle.editContext
        addContextViewController?.contextEntry = childEntry
        addContextViewController?.context = childContext
        addContextViewController?.delegate = self
        
    }
}

// MARK: NSFetchedResultsController
private extension ContextLightPatternListVC {
    
    func contextFetchedResultsController() -> NSFetchedResultsController<Context> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: contextFetchRequest(),
                                                                 managedObjectContext: coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func contextFetchRequest() -> NSFetchRequest<Context> {
        let fetchRequest:NSFetchRequest<Context> = Context.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Context.position), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func lightPatternFetchedResultsController() -> NSFetchedResultsController<LightPattern> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: lightPatternFetchRequest(),
                                                                 managedObjectContext: coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func lightPatternFetchRequest() -> NSFetchRequest<LightPattern> {
        let fetchRequest:NSFetchRequest<LightPattern> = LightPattern.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(LightPattern.name), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func deleteContext(at section: Int) {
        let sections = contextFetchedRC.fetchedObjects?[section]
        coreDataStack.mainContext.delete(sections!)
        coreDataStack.saveContext()
        
        guard let sectionUpperBound = contextFetchedRC.fetchedObjects?.count, sectionUpperBound > section + 1 else {
            return
        }
        
        for n in section...sectionUpperBound - 1 {
            let context = contextFetchedRC.fetchedObjects?[n]
            context?.position = Int16(n)
            coreDataStack.saveContext()
        }
    }
    
}
