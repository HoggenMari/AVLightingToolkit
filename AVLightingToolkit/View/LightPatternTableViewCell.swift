import UIKit
//import EFColorPicker

protocol CustomTableViewCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
    func colorTapped(_ sender: UIButton, indexPath: IndexPath, colorIndex: Int)
}

class LightPatternTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var radioButton: PlayButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    var cView: ColorPaletteView!
    var delegate: CustomTableViewCellDelegate?
    
    func initCellItem(for title: String, imageFileName: String?, color: [Data?], selected: Bool) {
        itemLabel.text = title
        
        if let filename = imageFileName, let image = ImageUtils.getImageFromDocumentPath(for: filename) {
            itemImage.image = image
        } else if let filename = imageFileName, let image = UIImage(named: filename) {
            itemImage.image = image
        } else {
            itemImage.image = UIImage(named: "brightness_pattern")
        }
        
        if let customView = Bundle.main.loadNibNamed("ColorPaletteView", owner: self, options: nil)?.first as? ColorPaletteView {
            if cView != nil {
                cView.removeFromSuperview()
            }
            cView = customView
            colorView.addSubview(cView)
            
            customView.translatesAutoresizingMaskIntoConstraints = false
            colorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":customView]))
            colorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":customView]))
            
            customView.initView(with: color)
            customView.delegate = self
        }
                
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemImageTapped))
        singleTap.numberOfTapsRequired = 1;
        itemImage.isUserInteractionEnabled = true
        itemImage?.addGestureRecognizer(singleTap)
        
        radioButton.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
        radioButton.isChecked = selected
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

extension LightPatternTableViewCell: ColorPaletteDelegate {
    func didTappedColor(_ sender: UIButton, colorIndex: Int) {
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.colorTapped(sender, indexPath: tappedCellIndexPath, colorIndex:  colorIndex)
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
