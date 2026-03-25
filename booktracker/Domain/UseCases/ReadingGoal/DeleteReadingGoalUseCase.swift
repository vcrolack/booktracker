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
    private let repository: ReadingGoalRepositoryProtocol
    
    init(repository: ReadingGoalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(readingGoalId: UUID) async throws {
        guard !(try await repository.fetchReadingGoals(criteria: ReadingGoalSearchField(id: readingGoalId))).isEmpty else {
            throw RepositoryError.notFound
        }
        
        try await repository.delete(by: readingGoalId)
    }
}
