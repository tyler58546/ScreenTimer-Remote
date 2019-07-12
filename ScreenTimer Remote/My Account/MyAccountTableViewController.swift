//
//  MyAccountTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/11/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import SwiftHTTP

class MyAccountTableViewController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField {
        case newPasswordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUsername()
    }
    
    func getLoginKey() -> String? {
        return UserDefaults.standard.value(forKey: "loginKey") as? String
    }
    
    func getUsername() {
        HTTP.GET("https://tyler58546.com/st/get-username.php?login=\(getLoginKey() ?? "error")") { response in
            if let error = response.error {
                return
            }
            if let str = String(data: response.data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.usernameLabel.text = str
                }
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 1 && indexPath.row == 2) {
            //Save
            if (newPasswordField.text == "" || newPasswordField.text == nil) {
                return
            }
            HTTP.POST("https://tyler58546.com/st/account-prefs.php", parameters: ["login":getLoginKey()!,"newpass":newPasswordField.text ?? "","confirm":confirmPasswordField.text ?? ""]) { response in
                var status = String(data: response.data, encoding: .utf8)
                if let error = response.error {
                    status = error.localizedDescription
                }
                var title = "Failed to Change Password"
                if status == "OK" {
                    title = "Password Changed"
                    status = "Your password has been successfully changed."
                    DispatchQueue.main.async {
                        self.newPasswordField.text = ""
                        self.confirmPasswordField.text = ""
                    }
                }
                let alert = UIAlertController(title: title, message: status, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (_) in
                    
                })
                alert.addAction(OKAction)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
        if (indexPath.section == 2 && indexPath.row == 0) {
            //Sign Out
            let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            let confirmAction = UIAlertAction(title: "Sign Out", style: .destructive, handler: {
                (_) in
                UserDefaults.standard.removeObject(forKey: "loginKey")
                self.navigationController?.tabBarController?.selectedViewController = self.navigationController?.tabBarController?.viewControllers![0]
                
            })
            alert.addAction(confirmAction)
            if let p = alert.popoverPresentationController {
                //ipad
                UserDefaults.standard.removeObject(forKey: "loginKey")
                self.navigationController?.tabBarController?.selectedViewController = self.navigationController?.tabBarController?.viewControllers![0]
                return
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (_) in
                
            })
            alert.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    

}
