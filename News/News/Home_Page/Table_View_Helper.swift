//
//  Table_View_Helper.swift
//  News
//
//  Created by Ryan Lehman on 7/1/18.
//

import Foundation
import UIKit

class table_view_helper: UIViewController {
    
    func timeDuration(date: String) throws -> String {
        
        let compareDateString = date
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let compareDate2 = dateFormatter.date(from:compareDateString)
        let currentDate = Date()
        
        let timeComponents: Set = [Calendar.Component.month,Calendar.Component.day,Calendar.Component.hour, Calendar.Component.minute]
        var time_interval = NSCalendar.current.dateComponents(timeComponents, from: compareDate2!, to: currentDate)
        
        if time_interval.day! > 1 {
            let date_Components: Set = [Calendar.Component.year,Calendar.Component.month,Calendar.Component.day]
            let past_date = NSCalendar.current.dateComponents(date_Components, from: compareDate2!)
            let year_string = "\(String(describing: past_date.year!))"
            let month_string = "\(String(describing: past_date.month!))"
            let day_stinrg = "\(String(describing: past_date.day!))"
            let final_String = month_string + "/" + day_stinrg + "/" + year_string
            return final_String
        } else {
            if time_interval.day != 0 {
                return "\(String(describing: time_interval.day!))d ago"
            } else if time_interval.hour != 0 {
                return "\(String(describing: time_interval.hour!))h ago"
            } else {
                return "\(String(describing: time_interval.minute!))m ago"
            }
        }
    }
    
}
