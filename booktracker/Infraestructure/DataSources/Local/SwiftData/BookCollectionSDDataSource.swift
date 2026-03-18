//
//  BookCollectionSDDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//

import Foundation
import SwiftData

protocol BookCollectionLocalDataSourceProtocol {
    func save(bookCollection: BookCollection) throws
    func fetchBookCollection(by id: UUID) throws -> BookCollection?
    func fetchBookCollections() throws -> [BookCollection]
    func deleteBookCollection(by id: UUID) throws
    func removeBookReferenceFromAllCollections(bookId: UUID) throws
}

final class BookCollectionSDDataSource: BookCollectionLocalDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save(bookCollection: BookCollection) throws {
        do {
            let collectionId = bookCollection.id
            
            var descriptor = FetchDescriptor<BookCollectionSD>(predicate: #Predicate { $0.id == collectionId })
            descriptor.fetchLimit = 1
            
            if let existingBookCollection = try context.fetch(descriptor).first {
                existingBookCollection.name = bookCollection.name
                existingBookCollection.collectionDescription = bookCollection.description
                existingBookCollection.coverFileName = bookCollection.cover
                existingBookCollection.bookIds = bookCollection.bookIds
                existingBookCollection.updatedAt = Date()
            } else {
                let newBookCollection = BookCollectionMapper.toDataModel(from: bookCollection)
                context.insert(newBookCollection)
            }
            
            try context.save()
        } catch {
            throw DataSourceError.saveFailed(error.localizedDescription)
        }
    }
    
    func fetchBookCollection(by id: UUID) throws -> BookCollection? {
        do {
            let bookCollectionId = id
            var descriptor = FetchDescriptor<BookCollectionSD>(predicate: #Predicate {$0.id == bookCollectionId })
            descriptor.fetchLimit = 1
            
            guard let bookCollectionSD = try context.fetch(descriptor).first else {
                return nil
            }
            
            return BookCollectionMapper.toDomain(from: bookCollectionSD)
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    func fetchBookCollections() throws -> [BookCollection] {
        do {
            let descriptor = FetchDescriptor<BookCollectionSD>()
            let fetchedModels = try context.fetch(descriptor)
            return fetchedModels.map { BookCollectionMapper.toDomain(from: $0) }
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    func deleteBookCollection(by id: UUID) throws {
        do {
            let bookCollectionId = id
            let descriptor = FetchDescriptor<BookCollectionSD>(predicate: #Predicate { $0.id == bookCollectionId })
            
            if let bookCollectionSD = try context.fetch(descriptor).first {
                context.delete(bookCollectionSD)
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
    
    func removeBookReferenceFromAllCollections(bookId: UUID) throws {
        do {
            let descriptor = FetchDescriptor<BookCollectionSD>()
            let allCollections = try context.fetch(descriptor)
            
            let collectionsToUpdate = allCollections.filter { $0.bookIds.contains(bookId) }
            
            guard !collectionsToUpdate.isEmpty else { return }
            
            for collection in collectionsToUpdate {
                collection.bookIds.remove(bookId)
                collection.updatedAt = Date()
            }
            
            try context.save()
        } catch {
            throw DataSourceError.deleteFailed("[BookCollectionSDDataSource] - removeBookReferenceFromAllCollections failed")
        }
    }
}
