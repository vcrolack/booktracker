//
//  ReadingGoal.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum ReadingGoalDomainError: Error, Equatable {
    case invalidTargetBooks
    case invalidTargetMinutes
}

struct ReadingGoal: Identifiable, Equatable, Codable {
    let id: UUID
    let year: Int
    
    private(set) var targetBooks: Int
    private(set) var targetMinutesPerDay: Int?
    
    let createdAt: Date
    
    init(id: UUID = UUID(), year: Int, targetBooks: Int, targetMinutesPerDay: Int? = nil) throws  {
        guard targetBooks >= 1 else {
            throw ReadingGoalDomainError.invalidTargetBooks
        }
        
        if let minutes = targetMinutesPerDay {
            guard minutes > 0 && minutes <= 1440 else {
                throw ReadingGoalDomainError.invalidTargetMinutes
            }
        }
        
        self.id = id
        self.year = year
        self.targetBooks = targetBooks
        self.targetMinutesPerDay = targetMinutesPerDay
        self.createdAt = Date()
    }
    
    init(
        reconstituting id: UUID,
        year: Int,
        targetBooks: Int,
        targetMinutesPerDay: Int?,
        createdAt: Date
    ) {
        self.id = id
        self.year = year
        self.targetBooks = targetBooks
        self.targetMinutesPerDay = targetMinutesPerDay
        self.createdAt = createdAt
    }
    
    mutating func updateGoals(newTargetBooks: Int? = nil, newTargetMinutesPerDay: Int? = nil) throws {
            
            if let books = newTargetBooks {
                guard books >= 1 else {
                    throw ReadingGoalDomainError.invalidTargetBooks
                }
                self.targetBooks = books
            }
            
            if let minutes = newTargetMinutesPerDay {
                guard minutes > 0 && minutes <= 1440 else {
                    throw ReadingGoalDomainError.invalidTargetMinutes
                }
                self.targetMinutesPerDay = minutes
            }
        }
}
