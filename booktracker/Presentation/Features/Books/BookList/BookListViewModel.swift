//
//  BookListViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class BookListViewModel {
    var books: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var currentFilter: BookFilter = BookFilter()
    
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchBooks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            books = try await repository.fetchBooks(matching: currentFilter)
        } catch {
            errorMessage = error.localizedDescription
            books = []
        }
        
        isLoading = false
    }
    
    func updateSearchTerm(_ term: String) async {
        currentFilter.searchItem = term.isEmpty ? nil : term
        await fetchBooks()
    }
    
    func updateStatusFilter(_ status: BookStatus) async {
        currentFilter.status = status
        await fetchBooks()
    }
    
    func deleteBook(at offsets: IndexSet) async {
        for index in offsets {
            let bookToDelete = books[index]
            do {
                try await repository.delete(bookId: bookToDelete.id)
            } catch {
                errorMessage = "Error al borrar: \(error.localizedDescription)"
                return
            }
        }
        
        await fetchBooks()
    }
    
    // MARK: - 🌱 Seed Data (Temporal)
        func addDummyBooks() async {
            do {
                // Un clásico fundacional
                let book1 = try Book(
                    title: "Neuromante",
                    author: "William Gibson",
                    pages: 271,
                    currentPage: 0,
                    ownership: .owner,
                    status: .toRead,
                    coverUrl: "https://ia800505.us.archive.org/view_archive.php?archive=/35/items/l_covers_0014/l_covers_0014_15.zip&file=0014155660-L.jpg"
                )
                
                // Un relato corto
                let book2 = try Book(
                    title: "Dagon",
                    author: "H. P. Lovecraft",
                    pages: 15,
                    currentPage: 15,
                    ownership: .owner, // O el caso que tengas en tu enum
                    status: .finalized
                )
                
                // Un manual técnico para variar
                let book3 = try Book(
                    title: "Clean Architecture",
                    author: "Robert C. Martin",
                    pages: 432,
                    currentPage: 120,
                    ownership: .borrowed,
                    status: .reading
                )
                
                // Guardamos en SQLite usando nuestro gerente
                try await repository.save(book: book1)
                try await repository.save(book: book2)
                try await repository.save(book: book3)
                
                // Recargamos la lista para que la UI se actualice
                await fetchBooks()
                
            } catch {
                errorMessage = "Error al sembrar datos: \(error.localizedDescription)"
            }
        }
}
