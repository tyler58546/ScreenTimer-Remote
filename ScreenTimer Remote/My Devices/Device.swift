//
//  Device.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/9/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation
import SwiftHTTP
import SwiftyJSON

struct Device {
    var name:String
    var timeLeft:Int?
    var lastUpdated:Int?
    var deviceID:String
    var id:String
    
    static func loadDevices(loginKey:String) {
        HTTP.GET("https://tyler58546.com/st/my-devices.php?key=\(loginKey)") { response in
            
            if let error = response.error {
                NotificationCenter.default.post(name: Notification.Name("noConnection"), object: nil)
                return
            }
            if (String(data: response.data, encoding: .utf8) == "") {
                NotificationCenter.default.post(name: Notification.Name("loginRequired"), object: nil)
                return
            }
            
            do {
                let json:JSON = try JSON(data: response.data)
                var devices:[Device] = []
                
                if json.count > 1 {
                    print(json.count)
                    for n in 0...(json.count - 2) {
                        devices.append(Device(name: json[String(n)]["name"].string ?? "(Unknown)", timeLeft: nil, lastUpdated: nil, deviceID: json[String(n)]["device"].string ?? "ERROR",id: json[String(n)]["id"].string ?? "error"))
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name("my_devices"), object: nil, userInfo: ["devices":devices])
            } catch {
                //json parse error
                print("my-devices.php: \(error.localizedDescription)")
            }
        }
    }
    static func loadLastPing(deviceID: String, i:Int) {
        HTTP.GET("https://tyler58546.com/st/last-ping.php?key=\(deviceID)") { response in
            if (String(data: response.data, encoding: .utf8) == "") {
                NotificationCenter.default.post(name: Notification.Name("loginRequired"), object: nil)
                return
            }
            do {
                let json = try JSON(data: response.data)
                let data:[String:Any] = ["i":i,"timeLeft":Int(json["timeLeft"].string!)!,"lastUpdated":Int(json["time"].string!)!]
                NotificationCenter.default.post(name: Notification.Name("last_ping"), object: nil, userInfo: data)
            } catch {
                //json parse error
                print("last-ping.php: \(error.localizedDescription)")
            }
        }
    }
    static func removeDevice(deviceID: String, loginKey: String) {
        HTTP.POST("https://tyler58546.com/st/remove-device.php", parameters: ["id":deviceID,"login":loginKey]) { response in
            NotificationCenter.default.post(name: Notification.Name("remove_device"), object: nil, userInfo: nil)
        }
    }
    static func renameDevice(deviceID:String, newName:String, loginKey:String) {
        if newName == "" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "rename_device"), object: nil, userInfo: ["status":"Not a valid name."])
            return
            
        }
        HTTP.POST("https://tyler58546.com/st/rename-device.php", parameters: ["login":loginKey,"newname":newName.replacingOccurrences(of: "'", with: ""),"device":deviceID]) { response in
            var responseString = String(data: response.data, encoding: .utf8) ?? "Server error"
            if let error = response.error {
                responseString = error.localizedDescription
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "rename_device"), object: nil, userInfo: ["status":responseString])
        }
    }
    func addTime(type:ScreenTimeType, duration:Int, password:String) {
        print("Adding time to \(self.name)...\nType: \(type.rawValue)\nDuration: \(duration)\nPassword: \(password)")
        HTTP.POST("https://tyler58546.com/st/add.php", parameters: ["key":self.deviceID,"type":type.rawValue,"duration":duration,"password":password]) { response in
            var status = String(data: response.data, encoding: .utf8)
            if let error = response.error {
                status = error.localizedDescription
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "add"), object: nil, userInfo: ["status":status ?? "Unknown error."])
        }
    }
}
