//
//  ToDoListTableViewCell.swift
//  ToDoListApp
//
//  Created by Tushar  Verma on 27.03.24.
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskCheckBtn: UIButton!
    @IBOutlet weak var hierarchicalNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
