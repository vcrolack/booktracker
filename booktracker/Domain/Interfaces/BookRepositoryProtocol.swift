//
//  BookRepositoryProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum RepositoryError: Error, Equatable {
    case notFound
    case saveFailed(reason: String)
    case fetchFailed(reason: String)
    case deleteFailed(reason: String)
}

struct BookFilter {
    var searchItem: String?
    var status: BookStatus?
    var ownership: Ownership?
    var author: String?
    var genre: String?
    
    var sortBy: SortOption? = .createdAtAscending
    
    enum SortOption {
        case titleAscending
        case createdAtAscending
        case createdAtDescending
        case ratingDescending
    }
}

protocol BookRepositoryProtocol {
    func fetchBooks(matching filter: BookFilter?) async throws -> [Book]
    func fetchBook(by id: UUID) async throws -> Book?
    
    func save(book: Book) async throws
    
    func delete(bookId: UUID) async throws
}
