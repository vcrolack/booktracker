//
//  FetchBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol FetchBooksUseCaseProtocol {
    func execute(filter: BookFilter?) async throws -> [Book]
}

final class FetchBooksUseCase: FetchBooksUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(filter: BookFilter? = nil) async throws -> [Book] {
        return try await repository.fetchBooks(matching: filter)
    }
}
