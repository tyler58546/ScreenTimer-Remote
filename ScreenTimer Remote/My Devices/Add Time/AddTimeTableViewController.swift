//
//  AddTimeTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/10/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class AddTimeTableViewController: UITableViewController {

    var selected1:IndexPath = IndexPath(row: 0, section: 1)
    var selected2:IndexPath = IndexPath(row: 0, section: 2)
    var selectedDevice:Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveScreenTime") {
            if let myDevicesVC = segue.destination as? MyDevicesTableViewController {
                var type:ScreenTimeType? {
                    switch selected1.row {
                    case 0:
                        return .new
                    case 1:
                        return .add
                    default:
                        return nil
                    }
                }
                var duration:Int? {
                    switch selected2.row {
                    case 0:
                        return 1
                    case 1:
                        return 5
                    case 2:
                        return 15
                    case 3:
                        return 30
                    case 4:
                        return 60
                    case 5:
                        return 120
                    default:
                        return nil
                    }
                }
                let password:String = (tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! TextInputTableViewCell).textField.text!
                myDevicesVC.addTime(type: type!, duration: duration!, device: selectedDevice!, password: password)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if selectedDevice == nil {
            return 0
        }
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 6
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "device",for: indexPath)
            cell.detailTextLabel?.text = selectedDevice?.name
            return cell
        }
        
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "type", for: indexPath) as! STTypeTableViewCell
            switch indexPath.row {
            case 0:
                cell.label.text = "New Screen Time"
            case 1:
                cell.label.text = "Additional Screen Time"
            default:
                break
            }
            cell.checked = (indexPath == selected1)
            return cell
        }
        
        if (indexPath.section == 2) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "duration", for: indexPath) as! STDurationTableViewCell
            
            switch (indexPath.row) {
            case 0:
                cell.label.text = "1 minute"
            case 1:
                cell.label.text = "5 minutes"
            case 2:
                cell.label.text = "15 minutes"
            case 3:
                cell.label.text = "30 minutes"
            case 4:
                cell.label.text = "1 hour"
            case 5:
                cell.label.text = "2 hours"
            default:
                break
            }
            cell.checked = (indexPath == selected2)
            return cell
        }
        
        if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textInput", for: indexPath) as! TextInputTableViewCell
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "save", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            (tableView.cellForRow(at: selected1) as! STTypeTableViewCell).checked = false
            selected1 = indexPath
            (tableView.cellForRow(at: indexPath) as! STTypeTableViewCell).checked = true
        case 2:
            (tableView.cellForRow(at: selected2) as! STDurationTableViewCell).checked = false
            selected2 = indexPath
            (tableView.cellForRow(at: indexPath) as! STDurationTableViewCell).checked = true
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Type"
        case 2:
            return "Duration"
        case 3:
            return "Device Password"
        default:
            return ""
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
