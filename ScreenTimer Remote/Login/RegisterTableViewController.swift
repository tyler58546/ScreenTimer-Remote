//
//  RegisterTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/11/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import SwiftHTTP

class RegisterTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        self.navigationItem.largeTitleDisplayMode = .never
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 2 && indexPath.row == 0) {
            if (passwordField.text == "" || passwordField.text == nil || usernameField.text == "" || usernameField.text == nil) {
                let alert = UIAlertController(title: "Registration Failed", message: "One or more fields are empty or invalid", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            HTTP.POST("https://tyler58546.com/st/register.php", parameters: ["username":usernameField.text,"password":passwordField.text,"confirm":confirmPasswordField.text]) { response in
                var status = String(data: response.data, encoding: .utf8)
                if let error = response.error {
                    status = error.localizedDescription
                }
                var title = "Registration Failed"
                var success = false
                if status == "OK" {
                    title = "Account Created Successfully"
                    status = "You may now log in."
                    success = true
                }
                let alert = UIAlertController(title: title, message: status, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (_) in
                    if (success) {
                        self.performSegue(withIdentifier: "exitToLogin", sender: self)
                    }
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }

}
