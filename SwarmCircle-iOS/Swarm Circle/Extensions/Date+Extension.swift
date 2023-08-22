//
//  Date+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 17/10/2022.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func timeAgo() -> String {
     
            let calendar = Calendar.current
            let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
            let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
            let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

            if minuteAgo < self {
                let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
                return "\(diff) sec ago"
            } else if hourAgo < self {
                let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
                return "\(diff) min ago"
            } else if dayAgo < self {
                let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
                return "\(diff) hrs ago"
            } else if weekAgo < self {
                let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
                return "\(diff) days ago"
            }
            let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
            return "\(diff) weeks ago"
        }
}

extension Date {
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    func isInSameYear (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(date: Date) -> Bool {  return isEqual(to: date, toGranularity: .month) }
    func isInSameDay  (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .day) }
    func isInSameWeek (date: Date) -> Bool {  return isEqual(to: date, toGranularity: .weekOfYear) }
    
    var isInThisYear:  Bool {  return isInSameYear(date: Date()) }
    var isInThisMonth: Bool {  return isInSameMonth(date: Date()) }
    var isInThisWeek:  Bool {  return isInSameWeek(date: Date()) }
    
    var isInYesterday: Bool {  return Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool {  return Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool {  return Calendar.current.isDateInTomorrow(self) }
    
    var isInTheFuture: Bool {  return self > Date() }
    var isInThePast:   Bool {  return self < Date() }
}
