import UIKit

protocol CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
}

class LightPatternTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemStackView: UIStackView!
    
    var delegate: CustomTableViewCellDelegate?
    
    func initCellItem() {
        
        let deselectedImage = UIImage(named: "radio_button_off")?.withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(named: "radio_button_on")?.withRenderingMode(.alwaysTemplate)
        radioButton.setImage(deselectedImage, for: .normal)
        radioButton.setImage(selectedImage, for: .selected)
        radioButton.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
                
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemImageTapped))
        singleTap.numberOfTapsRequired = 1;
        itemImage.isUserInteractionEnabled = true
        itemImage?.addGestureRecognizer(singleTap)
        
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        itemTapped()
    }
    
    @objc func itemImageTapped(_ imageItem: UIImage) {
        print("image item tapped")
        itemTapped()
    }
    
    func itemTapped() {
        print("radio button tapped")
        let isSelected = !self.radioButton.isSelected
        self.radioButton.isSelected = isSelected
        if isSelected {
            deselectOtherButton()
        }
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.didToggleRadioButton(tappedCellIndexPath)
    }
    
    func deselectOtherButton() {
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        let indexPaths = tableView.indexPathsForVisibleRows
        for indexPath in indexPaths! {
            if indexPath.row != tappedCellIndexPath.row && indexPath.section == tappedCellIndexPath.section {
                let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! LightPatternTableViewCell
                cell.radioButton.isSelected = false
            }
        }
    }
    
}
