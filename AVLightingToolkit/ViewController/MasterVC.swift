//
//  MasterVC.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 03.01.19.
//  Copyright © 2019 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

class MasterListItem {
    
    var description: String
    
    init(description: String) {
        self.description = description
    }

}

class MasterVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var listTableView: UITableView!
    
    var masterListItems: [MasterListItem] = []
    
    var controller: UIViewController!
    var controller2: LightPatternVC!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        masterListItems.append(MasterListItem.init(description: "All LightPatterns"))
        masterListItems.append(MasterListItem.init(description: "Configuration 1"))
        masterListItems.append(MasterListItem.init(description: "Configuration 2"))
        
        controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContextLightPattern")
        
        controller2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LightPattern") as? LightPatternVC
        controller2.viewModel = LightPatternViewModel()


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MasterListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "list") as! MasterListTableViewCell
        cell.name.text = masterListItems[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = masterListItems[indexPath.row]
        if selectedItem.description == "All LightPatterns" {
            splitViewController?.showDetailViewController(controller2, sender: nil)
        } else {
            splitViewController?.showDetailViewController(controller, sender: nil)
        }
    }
    
}
