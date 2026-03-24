//
//  ReadingGoalSD.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation
import SwiftData

@Model
final class ReadingGoalSD {
    @Attribute(.unique) var id: UUID
    var year: Int
    var targetBooks: Int
    var targetMinutesPerDay: Int?
    var createdAt: Date
    
    init(
        id: UUID,
        year: Int,
        targetBooks: Int,
        targetMinutesPerDay: Int? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.year = year
        self.targetBooks = targetBooks
        self.targetMinutesPerDay = targetMinutesPerDay
        self.createdAt = createdAt
    }
}
