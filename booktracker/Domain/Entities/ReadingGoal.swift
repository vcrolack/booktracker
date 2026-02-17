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
    
    init(id: UUID = UUID(), year: Int, targetBooks: Int, targetMinutesPerDay: Int? = nil)  {
        self.id = id
        self.year = year
        self.targetBooks = targetBooks
        self.targetMinutesPerDay = targetMinutesPerDay
        self.createdAt = Date()
    }
    
    mutating func updateGoals(newTargetBooks: Int? = nil, newTargetMinutesPerDay: Int? = nil) throws {
            
            // 1. Validar la meta de libros
            if let books = newTargetBooks {
                guard books >= 1 else {
                    // No puedes proponerte leer 0 o menos libros
                    throw ReadingGoalDomainError.invalidTargetBooks
                }
                self.targetBooks = books
            }
            
            // 2. Validar la meta de minutos diarios
            if let minutes = newTargetMinutesPerDay {
                // Un día tiene 1440 minutos. Leer más que eso o números negativos es un error.
                guard minutes > 0 && minutes <= 1440 else {
                    throw ReadingGoalDomainError.invalidTargetMinutes
                }
                self.targetMinutesPerDay = minutes
            }
        }
}
