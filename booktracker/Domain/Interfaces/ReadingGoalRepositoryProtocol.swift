//
//  ReadingGoalRepository.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

struct ReadingGoalSearchField {
    var year: Int?
    var id: UUID?
}

protocol ReadingGoalRepositoryProtocol {
    func fetchReadingGoals(criteria: ReadingGoalSearchField) async throws -> [ReadingGoal]
    func fetchReadingGoal(by id: UUID) async throws -> ReadingGoal?
    
    func save(goal: ReadingGoal) async throws
    
    func delete(by id: UUID) async throws
}
