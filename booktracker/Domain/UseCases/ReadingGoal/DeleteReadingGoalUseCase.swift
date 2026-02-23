//
//  DeleteReadingGoalUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol DeleteReadingGoalUseCaseProtocol {
    func execute(readingGoalId: UUID) async throws
}

final class DeleteReadingGoalUseCase: DeleteReadingGoalUseCaseProtocol {
    private let repository: ReadingGoalRepository
    
    init(repository: ReadingGoalRepository) {
        self.repository = repository
    }
    
    func execute(readingGoalId: UUID) async throws {
        guard let _ = try await repository.fetchReadingGoal(for: ReadingGoalSearchField(id: readingGoalId)) else {
            throw RepositoryError.notFound
        }
        
        try await repository.delete(readingGoalId: readingGoalId)
    }
}
