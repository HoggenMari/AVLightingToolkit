import UIKit

protocol CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
}

class LightPatternTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var radioButton: PlayButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemStackView: UIStackView!
    
    var delegate: CustomTableViewCellDelegate?
    
    func initCellItem() {
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
        radioButton.isChecked = !radioButton.isChecked
        itemTapped()
    }
    
    func itemTapped() {
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.didToggleRadioButton(tappedCellIndexPath)
    }
    
}

class PlayButton: UIButton {
    
    // Bool property
    public var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setIcon(icon: .googleMaterialDesign(.playCircleFilled), iconSize: 35, color: .darkGray, forState: .normal)
            } else {
                self.setIcon(icon: .googleMaterialDesign(.playCircleOutline), iconSize: 35, color: .gray, forState: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
