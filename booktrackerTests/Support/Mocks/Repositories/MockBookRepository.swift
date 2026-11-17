//
//  MockBookRepository.swift
//  booktracker
//
//  Created by Victor rolack on 17-11-26.
//

import Foundation
import Testing
@testable import booktracker

actor MockBookRepository: BookRepositoryProtocol {
    private let booksToReturn: [Book]
    private let errorToThrow: (any Error)?
    
    private(set) var fetchBooksCallCount = 0
    private(set) var receivedFilters: [BookFilter?] = []
    
    init(books: [Book] = [], error: (any Error)? = nil) {
        self.booksToReturn = books
        self.errorToThrow = error
    }
    
    func fetchBooks(matching filter: BookFilter?) async throws -> [Book] {
        fetchBooksCallCount += 1
        receivedFilters.append(filter)
        
        if let errorToThrow { throw errorToThrow }
        return booksToReturn
    }
    
    func fetchBook(by id: UUID) async throws -> booktracker.Book? {
        Issue.record("fetchBook no should call in this test")
        return nil
    }
    
    func save(book: booktracker.Book) async throws {
        Issue.record("save no should call in this test")
    }
    
    func delete(bookId: UUID) async throws {
        Issue.record("delete no should call in this test")
    }
    
}
