//
//  AddBookViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import Observation

@MainActor
@Observable
class BookFormViewModel {
    private var editingBook: Book?
    
    var title: String = ""
    var author: String = ""
    var pages: String = ""
    var coverUrl: String = ""
    var isbn: String = ""
    var editorial: String = ""
    var genre: String = ""
    var overview: String = ""
    var currentPage: String = ""
    var status: BookStatus = .wishlist
    var ownership: Ownership = .notOwner
    
    var isSaving: Bool = false
    var errorMessage: String? = nil
    
    private let createBookUseCase: CreateBookUseCaseProtocol
    private let updateBookDetailsUseCase: UpdateBookDetailsUseCaseProtocol
    
    init (
        book: Book? = nil,
        createBookUseCase: CreateBookUseCaseProtocol,
        updateBookDetailsUseCase: UpdateBookDetailsUseCaseProtocol,
    ) {
        self.editingBook = book
        self.createBookUseCase = createBookUseCase
        self.updateBookDetailsUseCase = updateBookDetailsUseCase
        
        if let book = book {
            self.title = book.title
            self.author = book.author
            self.pages = String(book.pages)
            self.coverUrl = book.coverUrl ?? ""
            self.isbn = book.isbn ?? ""
            self.editorial = book.editorial ?? ""
            self.genre = book.genre ?? ""
            self.overview = book.overview ?? ""
            self.status = book.status
            self.ownership = book.ownership
        }
    }
    
    func saveBook() async -> Bool {
        isSaving = true
        errorMessage = nil
        
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El título es obligatorio"
            isSaving = false
            return false
        }
        
        guard !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El autor es obligatorio"
            isSaving = false
            return false
        }
        
        let totalPages = Int(pages) ?? 0
        let currentPage = Int(currentPage) ?? 0
        let cleanedUrl = coverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            if let book = editingBook {
                let command = UpdateBookCommand(
                    bookId: book.id,
                    title: title,
                    author: author,
                    pages: totalPages,
                    editorial: editorial.isEmpty ? nil : editorial,
                    isbn: isbn.isEmpty ? nil : isbn,
                    ownership: ownership,
                    coverUrl: cleanedUrl.isEmpty ? nil : cleanedUrl,
                    genre: genre.isEmpty ? nil : genre,
                    overview: overview.isEmpty ? nil : overview,
                )
                let _ = try await updateBookDetailsUseCase.execute(command: command)
            } else {
                let newBook = CreateBookCommand(
                    title: title,
                    author: author,
                    pages: totalPages,
                    ownership: ownership,
                    status: status,
                    isbn: isbn,
                    coverUrl: cleanedUrl,
                    editorial: editorial,
                    genre: genre,
                    overview: overview,
                    currentPage: currentPage
                )
                
                let _ = try await createBookUseCase.execute(command: newBook)
            }
            
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
    
    var isEditing: Bool {
        return editingBook != nil
    }
}
