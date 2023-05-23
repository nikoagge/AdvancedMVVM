//
//  ToDoItemTableViewCell.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 16/5/23.
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var toDoTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(withViewModel viewModel: ToDoItemPresentable) -> (Void) {
        indexLabel.text = viewModel.id

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: viewModel.textValue ?? "")

        if viewModel.isDone! {
            let range = NSMakeRange(0, attributedString.length)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.lightGray, range: range)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
        }

        toDoTitleLabel.attributedText = attributedString
    }
}
