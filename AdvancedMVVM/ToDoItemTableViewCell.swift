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
        toDoTitleLabel.text = viewModel.textValue
    }
}
