//
//  BookCollectionDetailViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 19-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BookCollectionDetailViewModel {
    var bookCollection: BookCollection
    var books: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var bookCountsByStatus: [BookStatus: Int] {
        books.reduce(into: [BookStatus: Int]()) { counts, book in
            counts[book.status, default: 0] += 1
        }
    }
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let updateBookCollectionUseCase: UpdateBookCollectionUseCaseProtocol
    
    init(
        bookCollection: BookCollection,
        fetchBooksUseCase: FetchBooksUseCaseProtocol,
        updateBookCollectionUseCase: UpdateBookCollectionUseCaseProtocol
    ) {
        self.bookCollection = bookCollection
        self.fetchBooksUseCase = fetchBooksUseCase
        self.updateBookCollectionUseCase = updateBookCollectionUseCase
    }
    
    func loadBooks() async {
        isLoading = true
        do {
            let filter = BookFilter(ids: bookCollection.bookIds, sortBy: .titleAscending)
            self.books = try await fetchBooksUseCase.execute(filter: filter)
        } catch {
            errorMessage = "No hemos logrado cargar tus libros"
            print("[BC DETAIL VM] Failed to fetch books: \(error)")
        }
        isLoading = false
    }
    
    func updateBooks(newIds: Set<UUID>) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let command = UpdateBookCollectionCommand(bookCollectionId: bookCollection.id, bookIds: newIds)
            
            _ = try await updateBookCollectionUseCase.execute(command: command)
            
            try self.bookCollection.updateBookCollection(name: bookCollection.name, description: bookCollection.description, cover: bookCollection.cover, bookIds: newIds)
            
            await loadBooks()
            
            print("[BC DETAIL VM] collection updated successfully with \(newIds) books")
        } catch {
            print("[BC DETAIL VM] Failed to update collection: \(error)")
            errorMessage = "No hemos logrado actualizar tus libros."
        }
    }
}
