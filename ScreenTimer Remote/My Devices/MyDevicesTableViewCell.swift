//
//  MyDevicesTableViewCell.swift
//  ScreenTimer Remote
//
//  Created by Tyler Knox on 7/9/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class MyDevicesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var onlineCircle: UIImageView!
    

    
    func formatTimeLeft(_ seconds:Int) -> String {
        
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        
        var hh:String = "\(h)"
        var mm:String = "\(m)"
        
        if h < 10 {
            hh = "0\(h)"
        }
        if m < 10 {
            mm = "0\(m)"
        }
        
        return "\(hh):\(mm)"
    }
    
    var device:Device? {
        didSet {
            guard let device = device else { return }
            
            deviceNameLabel.text = device.name
            timeLeftLabel.text = formatTimeLeft(device.timeLeft!*60)
            if device.lastUpdated! > (Int(Date().timeIntervalSince1970)-20) {
                lastUpdatedLabel.text = "Online"
                onlineCircle.image = UIImage(named: "online")
            } else {
                lastUpdatedLabel.text = "Last online: \(Date(timeIntervalSince1970: TimeInterval(device.lastUpdated!)).timeAgoSinceDate(numericDates: false))"
                onlineCircle.image = UIImage(named: "offline")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension Date {
    func timeAgoSinceDate(numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        if let year = components.year {
            if (year >= 2) {
                return "\(year) years ago"
            } else if (year >= 1) {
                return stringToReturn(flag: numericDates, strings: ("1 year ago", "Last year"))
            }
        }
        
        if let month = components.month {
            if (month >= 2) {
                return "\(month) months ago"
            } else if (month >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 month ago", "Last month"))
            }
        }
        
        if let weekOfYear = components.weekOfYear {
            if (weekOfYear >= 2) {
                return "\(weekOfYear) months ago"
            } else if (weekOfYear >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 week ago", "Last week"))
            }
        }
        
        if let day = components.day {
            if (day >= 2) {
                return "\(day) days ago"
            } else if (day >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 day ago", "Yesterday"))
            }
        }
        
        if let hour = components.hour {
            if (hour >= 2) {
                return "\(hour) hours ago"
            } else if (hour >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 hour ago", "An hour ago"))
            }
        }
        
        if let minute = components.minute {
            if (minute >= 2) {
                return "\(minute) minutes ago"
            } else if (minute >= 2) {
                return stringToReturn(flag: numericDates, strings: ("1 minute ago", "A minute ago"))
            }
        }
        
        if let second = components.second {
            if (second >= 3) {
                return "\(second) seconds ago"
            }
        }
        
        return "Just now"
    }
    
    private func stringToReturn(flag:Bool, strings: (String, String)) -> String {
        if (flag){
            return strings.0
        } else {
            return strings.1
        }
    }
}
