//
//  AddDeviceTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/10/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import SwiftHTTP

class AddDeviceTableViewController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var deviceIDField: UITextField!
    @IBOutlet weak var devicePasswordField: UITextField!
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        HTTP.POST("https://tyler58546.com/st/add-device.php", parameters: ["name":(nameField.text ?? "").replacingOccurrences(of: "'", with: ""),"key":deviceIDField.text ?? "","password":devicePasswordField.text ?? "","login":"UXWKFFK9DY"]) { response in
            
            
            
            var text = String(data: response.data, encoding: .utf8 ) ?? "Server error"
            if let error = response.error {
                text = error.localizedDescription
            }
            if text != "OK" {
                let alert = UIAlertController(title: "Failed to add device.", message: text, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (_)in
                })
                alert.addAction(OKAction)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "saveDevice", sender: self)
                }
            }
            
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        deviceIDField.delegate = self
        devicePasswordField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case nameField:
            deviceIDField.becomeFirstResponder()
        case deviceIDField:
            devicePasswordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
}

