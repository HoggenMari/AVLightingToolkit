//
//  ViewController.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 07.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import UIKit
import CoreData

class ContextPatternListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var coreDataStack = CoreDataStack(modelName: "AVLightingToolkit")
    var fetchedResultsController: NSFetchedResultsController<Context> = NSFetchedResultsController()
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet var lightPatternTableView: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addViewHeightConstraint: NSLayoutConstraint!
    
    var newContextEntry: Context?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        fetchedResultsController = contextFetchedResultsController()
        
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
        

        let sections = fetchedResultsController.fetchedObjects?[section]
        
        headerView.contextTitle.text = sections?.name
        
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
        let sections = fetchedResultsController.fetchedObjects?[section]
        return sections?.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsController.fetchedObjects?.count ?? 0
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?[section].lightpatterns?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomiseTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomiseTableViewCell
        
        let pattern = fetchedResultsController.fetchedObjects?[indexPath.section].lightpatterns?.allObjects[indexPath.row] as! LightPattern
        
        cell.itemLabel?.text = pattern.name
        
        return cell
        
    }
}

extension ContextPatternListViewController: AddItemFooterViewDelegate, OverlayHost {
    func addContextButtonTapped() {
        print("addContextButtonTapped")
        
        let addContextViewController = showOverlay(type: AddContextViewController.self, fromStoryboardWithName: "Main")
        
        newContextEntry = Context(context: coreDataStack.mainContext)
        newContextEntry?.position = Int16(fetchedResultsController.fetchedObjects?.count ?? 0)
        
        addContextViewController?.controllerTitle = AddContextViewControllerTitle.newContext
        addContextViewController?.contextEntry = newContextEntry
        addContextViewController?.context = newContextEntry?.managedObjectContext
        addContextViewController?.delegate = self
            }
    
    func addLightingPatternTapped() {
        print("addLightPatternButtonTapped")
    }
    
}

extension ContextPatternListViewController: CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath) {
        //do nothing
    }
}

extension ContextPatternListViewController: NSFetchedResultsControllerDelegate {
    
    func didFinish(viewController: AddContextViewController, didSave: Bool) {
        print("didFinish")
        
        // 1
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
        // 2
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            // 3
            self.coreDataStack.saveContext()
        }
        // 4
        dismiss(animated: true)
    }
}

extension ContextPatternListViewController: ContextEntryDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        lightPatternTableView.reloadData()
    }
    
}
// MARK: NSFetchedResultsController
private extension ContextPatternListViewController {
    
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
    
}
