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
    private let books: [Book]
    private let fetchError: (any Error)?
    private let deleteError: (any Error)?
    private let recorder: CallRecorder?
    private let error: (any Error)?
    
    private(set) var fetchBooksCallCount = 0
    private(set) var receivedFilters: [BookFilter?] = []
    
    init(
        books: [Book] = [],
        fetchError: (any Error)? = nil,
        deleteError: (any Error)? = nil,
        recorder: CallRecorder? = nil,
        error: (any Error)? = nil
    ) {
        self.books = books
        self.fetchError = fetchError
        self.deleteError = deleteError
        self.recorder = recorder
        self.error = error
    }
    
    func fetchBooks(matching filter: BookFilter?) async throws -> [Book] {
        fetchBooksCallCount += 1
        receivedFilters.append(filter)
        
        if let fetchError { throw fetchError }
        if let error { throw error }
        return books
    }
    
    func fetchBook(by id: UUID) async throws -> Book? {
        await recorder?.record(.fetchBook(id))
        if let fetchError { throw fetchError }
        if let error { throw error }
        return books.first { $0.id == id }
    }
    
    func save(book: booktracker.Book) async throws {
        Issue.record("save no should call in this test")
    }
    
    func delete(bookId: UUID) async throws {
        await recorder?.record(.deleteBook(bookId))
        if let deleteError { throw deleteError }
        if let error { throw error }
    }
}
