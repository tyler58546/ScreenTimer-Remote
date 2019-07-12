//
//  LoginTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/11/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftyJSON

class LoginTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func exitToLogin(_ segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 1 && indexPath.row == 0) {
            HTTP.POST("https://tyler58546.com/st/login.php", parameters: ["username":usernameField.text,"password":passwordField.text]) { response in
                if let error = response.error {
                    DispatchQueue.main.async {
                        self.showLoginError(error.localizedDescription)
                    }
                    return
                }
                do {
                    let json = try JSON(data: response.data)
                    if (json["success"].bool == true) {
                        UserDefaults.standard.set(json["key"].string!, forKey: "loginKey")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "loginComplete", sender: self)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showLoginError("Incorrect username or password.")
                        }
                    }
                } catch {
                    
                }
            }
        }
    }

    
    func showLoginError(_ status:String) {
        let alert = UIAlertController(title: "Login Failed", message: status, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {
            (_)in
            
        })
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
}
