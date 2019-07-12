//
//  STDurationTableViewCell.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/10/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class STDurationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var label: UILabel!
    
    var checked:Bool? {
        didSet {
            guard let checked = checked else {return}
            if (checked) {
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
