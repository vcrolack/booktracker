//
//  BookRepositoryImpl.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation

final class BookRepositoryImpl: BookRepositoryProtocol {
    private let localDataSource: BookLocalDataSourceProtocol
    
    init(localDataSource: BookLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func save(book: Book) async throws {
        try localDataSource.save(book: book)
    }
    
    func fetchBook(by id: UUID) async throws -> Book? {
        return try localDataSource.fetchBook(by: id)
    }
    
    func fetchBooks(matching filter: BookFilter?) async throws -> [Book] {
       return try localDataSource.fetchBooks(matching: filter)
    }
    
    func delete(bookId: UUID) async throws {
        try localDataSource.deleteBook(by: bookId)
    }
}
