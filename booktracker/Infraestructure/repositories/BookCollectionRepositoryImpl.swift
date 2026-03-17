//
//  BookCollectionRepositoryImpl.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//

import Foundation

final class BookCollectionRepositoryImpl: BookCollectionRepositoryProtocol {
    private let localDataSource: BookCollectionLocalDataSourceProtocol
    
    init(localDataSource: BookCollectionLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func save(bookCollection: BookCollection) async throws {
        try localDataSource.save(bookCollection: bookCollection)
    }
    
    func fetchCollection(by id: UUID) async throws -> BookCollection? {
        return try localDataSource.fetchBookCollection(by: id)
    }
    
    func fetchCollections(matching filter: BookCollectionFilter?) async throws -> [BookCollection] {
        return try localDataSource.fetchBookCollections()
    }
    
    func delete(by id: UUID) async throws {
        try localDataSource.deleteBookCollection(by: id)
    }
    
    func removeBookReferenceFromAllCollections(bookId: UUID) async throws {
        try localDataSource.removeBookReferenceFromAllCollections(bookId: bookId)
    }
}
