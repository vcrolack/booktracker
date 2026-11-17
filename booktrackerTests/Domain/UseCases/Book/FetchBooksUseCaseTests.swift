//
//  FetchBooksUseCaseTests.swift
//  booktracker
//
//  Created by Victor rolack on 17-11-26.
//

import Foundation
import Testing
@testable import booktracker

@Suite("FetchBooksUseCase")
struct FetchBooksUseCaseTests {
    @Test("Returns books from the repository")
    func returnsBooksFromRepository() async throws {
        let books = [
            try Book.fixture(title: "Dune"),
            try Book.fixture(title: "1984")
        ]
        let repository = MockBookRepository(books: books)
        let sut = FetchBooksUseCase(repository: repository)
        
        let result = try await sut.execute(filter: nil)
        
        #expect(result == books)
    }
    
    @Test("Call the repository onces and receives the filter")
    func forwardsFilterToRepository() async throws {
        let repository = MockBookRepository()
        let sut = FetchBooksUseCase(repository: repository)
        let filter = BookFilter(status: .reading)
        
        _ = try await sut.execute(filter: filter)
        
        #expect(await repository.fetchBooksCallCount == 1)
        #expect(await repository.receivedFilters == [filter])
    }
    
    @Test("Propagate the repository's error")
    func propagatesRepositoryError() async {
        let repository = MockBookRepository(error: DataSourceError.fetchFailed("Booom!"))
        let sut = FetchBooksUseCase(repository: repository)
        
        await #expect(throws: DataSourceError.self) {
            try await sut.execute(filter: nil)
        }
    }
}
