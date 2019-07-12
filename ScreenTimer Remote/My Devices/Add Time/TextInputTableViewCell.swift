//
//  TextInputTableViewCell.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/11/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class TextInputTableViewCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if textField != nil {
            textField.delegate = self
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
