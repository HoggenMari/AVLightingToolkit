import UIKit

/*protocol CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
}*/

class AllLightPatternTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemStackView: UIStackView!
    
    var delegate: CustomTableViewCellDelegate?
    
    func initCellItem(for title: String, imageFileName: String?, selected: Bool) {
        itemLabel.text = title
        
        if let filename = imageFileName, let image = ImageUtils.getImageFromDocumentPath(for: filename) {
            itemImage.image = image
        } else if let filename = imageFileName, let image = UIImage(named: filename) {
            itemImage.image = image
        } else {
            itemImage.image = UIImage(named: "brightness_pattern")
        }
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemImageTapped))
        singleTap.numberOfTapsRequired = 1;
        itemImage.isUserInteractionEnabled = true
        itemImage?.addGestureRecognizer(singleTap)
        
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        itemTapped()
    }
    
    @objc func itemImageTapped(_ imageItem: UIImage) {
        itemTapped()
    }
    
    func itemTapped() {
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.didToggleRadioButton(tappedCellIndexPath)
    }
    
}
