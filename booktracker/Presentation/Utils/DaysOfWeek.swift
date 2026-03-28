//
//  DaysOfWeek.swift
//  booktracker
//
//  Created by Victor rolack on 27-03-26.
//

import Foundation

extension Calendar {
    func daysOfWeek(containing date: Date) -> [Date] {
        guard let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return []
        }
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}
