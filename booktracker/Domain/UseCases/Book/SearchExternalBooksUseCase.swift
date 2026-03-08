//
//  SearchExternalBooksUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//
import Foundation

protocol SearchExternalBooksUseCaseProtocol {
    func execute(query: String) async throws -> [Book]
}

class SearchExternalBooksUseCase: SearchExternalBooksUseCaseProtocol {
    private let provider: ExternalBookProviderProtocol
    
    init(provider: ExternalBookProviderProtocol) {
        self.provider = provider
    }
    
    func execute(query: String) async throws -> [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            return []
        }
        
        return try await provider.searchBooks(query: trimmedQuery)
    }
}
