//
//  CollectionRepositoryProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

struct BookCollectionFilter {
    var searchItem: String?
    
    var sortBy: SortOption? = .nameDescending
    
    enum SortOption {
        case nameDescending
        case nameAscending
    }
}

protocol BookCollectionRepositoryProtocol {
    func fetchCollection(by id: UUID) async throws -> BookCollection?
    func fetchCollections(matching filter: BookCollectionFilter?) async throws -> [BookCollection]
    
    func save(bookCollection: BookCollection) async throws
    func delete(bookCollection: BookCollection) async throws
    func deleteBookFromAll(bookId: UUID) async throws
}
