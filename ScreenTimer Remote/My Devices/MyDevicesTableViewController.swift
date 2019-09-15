//
//  MyDevicesTableViewController.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/9/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit


enum ScreenTimeType:String {
    case new = "new"
    case add = "add"
}

class MyDevicesTableViewController: UITableViewController {
    @IBOutlet weak var noDevicesView: UIView!
    
    var data:[Device] = []
    var incompleteData:[Device] = []
    var timer = Timer()
    var enableRefresh = true
    
    @IBAction func cancelToMyDevices(_ segue: UIStoryboardSegue) {
        print("cancel")
    }
    
    @IBAction func saveNewDevice(_ segue: UIStoryboardSegue) {
        print("save")
    }
    
    @IBAction func loginComplete(_ segue: UIStoryboardSegue) {
        refresh()
    }
    
    @IBAction func saveScreenTime(_ segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openAdd" {
            if let dest = segue.destination as? UINavigationController {
                let senderCell = sender as! MyDevicesTableViewCell
                (dest.viewControllers.first as! AddTimeTableViewController).selectedDevice = senderCell.device
            }
        }
    }
    
    
    
    
    
    @objc func myDevicesHandler(_ notification: Notification) {
        incompleteData = notification.userInfo!["devices"] as! [Device]
        if incompleteData.count > 0 {
            DispatchQueue.main.async {
                self.noDevicesView.isHidden = true
            }
            for i in 0...(incompleteData.count-1) {
                Device.loadLastPing(deviceID: incompleteData[i].deviceID, i:i)
            }
        } else {
            //No devices added
            DispatchQueue.main.async {
                self.noDevicesView.isHidden = false
            }
        }
    }
    @objc func lastPingHandler(_ notification: Notification) {
        let timeLeft = notification.userInfo!["timeLeft"] as! Int
        //print(timeLeft)
        let lastUpdated = notification.userInfo!["lastUpdated"] as! Int
        let ii = notification.userInfo!["i"] as! Int
        incompleteData[ii] = Device(name: incompleteData[ii].name, timeLeft: timeLeft, lastUpdated: lastUpdated, deviceID: incompleteData[ii].deviceID, id: incompleteData[ii].id)
        
        
        
        if allOK(incompleteData) {
            data = incompleteData
            print(data)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
        
        
    }
    
    @objc func removeDeviceHandler(_ notification: Notification) {
        enableRefresh = true
    }
    
    @objc func renameDeviceHandler(_ notification: Notification) {
        if notification.userInfo!["status"] as! String != "OK" {
            let alert = UIAlertController(title: "Failed to rename device.", message: notification.userInfo!["status"] as? String, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                (_)in
            })
            alert.addAction(OKAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            refresh()
        }
    }
    
    @objc func addHandler(_ notification: Notification) {
        let status = notification.userInfo!["status"] as! String
        var title:String {
            if status == "Success! Note: It may take a while for the timer to update." {
                return "Screen Time Added"
            }
            return "Failed to Add Screen Time"
        }
        let alert = UIAlertController(title: title, message: status, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (_)in
            DispatchQueue.main.async {
                self.refresh()
            }
        })
        alert.addAction(OKAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func allOK(_ input:[Device]) -> Bool {
        var ok = true
        for device in input {
            if device.timeLeft == nil {
                ok = false
            }
        }
        return ok
    }
    
    @objc func refresh() {
        if enableRefresh {
            if let loginKey = getLoginKey() {
                Device.loadDevices(loginKey: loginKey)
            }
        }
    }
    
    func addTime(type:ScreenTimeType, duration:Int, device:Device, password:String) {
        device.addTime(type: type, duration: duration, password: password)
    }
    
    func login() -> Bool {
        if getLoginKey() != nil {
            return true
        } else {
            showLoginVC()
            return false
        }
    }
    
    func getLoginKey() -> String? {
        return UserDefaults.standard.value(forKey: "loginKey") as? String
    }
    
    @objc func showLoginVC() {
        DispatchQueue.main.async {
            let vc:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "login"))!
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func noConnection() {
        let vc:UIViewController = (storyboard?.instantiateViewController(withIdentifier: "noConnection"))!
        DispatchQueue.main.async {
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .formSheet
        self.navigationController?.modalPresentationStyle = .formSheet
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.myDevicesHandler), name: Notification.Name(rawValue: "my_devices"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.lastPingHandler), name: Notification.Name(rawValue: "last_ping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeDeviceHandler), name: Notification.Name(rawValue: "remove_device"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.renameDeviceHandler), name: Notification.Name(rawValue: "rename_device"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addHandler), name: Notification.Name(rawValue: "add"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLoginVC), name: Notification.Name(rawValue: "loginRequired"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.noConnection), name: Notification.Name(rawValue: "noConnection"), object: nil)
        
        
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        if !(login()) { return }
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! MyDevicesTableViewCell

        // Configure the cell...
        cell.device = data[indexPath.row]
        cell.selectionStyle = .blue

        return cell
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
            let theDevice = data[indexPath.row]
            data.remove(at: indexPath.row)
            incompleteData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            enableRefresh = false
            Device.removeDevice(deviceID: theDevice.id, loginKey: "UXWKFFK9DY")
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // Delete the row from the data source
            DispatchQueue.main.async {
                let theDevice = self.data[indexPath.row]
                self.data.remove(at: indexPath.row)
                self.incompleteData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.enableRefresh = false
                Device.removeDevice(deviceID: theDevice.id, loginKey: self.getLoginKey()!)
            }
            
        }
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { (action, indexPath) in
            let alert = UIAlertController(title: "Rename Device", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Device Name..."
                textField.text = self.data[indexPath.row].name
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                if let name = alert.textFields?.first?.text {
                    Device.renameDevice(deviceID: self.data[indexPath.row].id, newName: name, loginKey: self.getLoginKey()!)
                }
            }))
            
            self.present(alert, animated: true)
        }
        return [delete,rename]
    }
    

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


class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
    
}
