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

protocol ReadingGoalRepository {
    func fetchReadingGoals() async throws -> [ReadingGoal]
    func fetchReadingGoal(for searchField: ReadingGoalSearchField) async throws -> ReadingGoal?
    
    func save(readingGoal: ReadingGoal) async throws
    
    func delete(readingGoalId: UUID) async throws
}
