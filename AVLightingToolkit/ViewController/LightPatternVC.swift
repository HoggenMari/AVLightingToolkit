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

class LightPatternVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
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
        
        table.delegate = self
        table.dataSource = self
        
        lightPattern.setIcon(prefixText: "", icon: .googleMaterialDesign(.blurOn), iconColor: .gray, postfixText: "Add Light Pattern", postfixTextColor: .darkGray, cgRect: CGRect(x: 0, y: 0, width: 0, height: 0), size: 18, target: self, action: #selector(buttonAction(sender:)))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfLightPatterns ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LightPatternTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "cell") as! LightPatternTableViewCell
        
        if let lightpattern = viewModel?.lightPattern(at: indexPath) {
            cell.initCellItem(for: lightpattern.name, imageFileName: lightpattern.imageFilename, selected: false)
        }
        
        return cell
    }
    
    @objc func buttonAction(sender: UIBarButtonItem) {
        print("test")
    }
    
    
}
