//
//  SwiftDataLocalDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import SwiftData

protocol BookLocalDataSourceProtocol {
    func save(book: Book) throws
    func fetchBook(by id: UUID) throws -> Book?
    func fetchBooks(matching filter: BookFilter?) throws -> [Book]
    func deleteBook(by id: UUID) throws
}

final class BookSDDataSource: BookLocalDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save (book: Book) throws {
        do {
            let bookSD = BookMapper.toDataModel(from: book)
            context.insert(bookSD)
            try context.save()
        } catch {
            throw DataSourceError.saveFailed(error.localizedDescription)
        }
    }
    
    func fetchBook(by id: UUID) throws -> Book? {
        do {
            var descriptor = FetchDescriptor<BookSD>(
                predicate: #Predicate { $0.id == id }
            )
            
            descriptor.fetchLimit = 1
            
            guard let bookSD = try context.fetch(descriptor).first else {
                return nil
            }
            
            return BookMapper.toDomain(from: bookSD)
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    func fetchBooks(matching filter: BookFilter? = nil) throws -> [Book] {
        do {
            var sortDescriptors: [SortDescriptor<BookSD>] = []
            
            let activeSort = filter?.sortBy ?? .createdAtAscending
            
            switch activeSort {
            case .titleAscending:
                sortDescriptors.append(SortDescriptor(\.title, order: .forward))
            case .createdAtAscending:
                sortDescriptors.append(SortDescriptor(\.createdAt, order: .forward))
            case .createdAtDescending:
                sortDescriptors.append(SortDescriptor(\.createdAt, order: .reverse))
            case .ratingDescending:
                sortDescriptors.append(SortDescriptor(\.userRating, order: .reverse))
            }
            
            var descriptor = FetchDescriptor<BookSD>(sortBy: sortDescriptors)
            
            if let activeFilter = filter {
                let targetStatus = activeFilter.status?.rawValue
                let filterByStatus = targetStatus != nil
                
                let targetOwnership = activeFilter.ownership?.rawValue
                let filterByOwnership = targetOwnership != nil
                
                let searchItem = activeFilter.searchItem ?? ""
                let filterBySearchItem = !searchItem.isEmpty
                
                let targetAuthor = activeFilter.author ?? ""
                let filterByAuthor = !targetAuthor.isEmpty
                
                let targetGenre: String? = activeFilter.genre
                let filterByGenre = (targetGenre != nil && targetGenre != "")
                
                descriptor.predicate = #Predicate<BookSD> { bookSD in
                    (filterByStatus == false || bookSD.statusRawValue == targetStatus) &&
                    (filterByOwnership == false || bookSD.ownershipRawValue == targetOwnership) &&
                    (filterBySearchItem == false || bookSD.title.contains(searchItem)) &&
                    (filterByAuthor == false || bookSD.author.contains(targetAuthor)) &&
                    (filterByGenre == false || bookSD.genre == targetGenre)
                }
            }
            
            let booksSD = try context.fetch(descriptor)
            
            return booksSD.map { BookMapper.toDomain(from: $0) }
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    func deleteBook(by id: UUID) throws {
        do {
            let descriptor = FetchDescriptor<BookSD>(predicate: #Predicate { $0.id == id })
            
            if let bookSD = try context.fetch(descriptor).first {
                context.delete(bookSD)
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
}
