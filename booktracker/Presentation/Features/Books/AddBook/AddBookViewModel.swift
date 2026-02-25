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
class AddBookViewModel {
    var title: String = ""
    var author: String = ""
    var pages: String = ""
    var coverUrl: String = ""
    var isbn: String = ""
    var status: BookStatus = .wishlist
    var ownership: Ownership = .notOwner
    
    var isSaving: Bool = false
    var errorMessage: String? = nil
    
    private let createBookUseCase: CreateBookUseCaseProtocol
    
    init (createBookUseCase: CreateBookUseCaseProtocol) {
        self.createBookUseCase = createBookUseCase
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
        let cleanedUrl = coverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let newBook = CreateBookCommand(
                title: title,
                author: author,
                pages: totalPages,
                ownership: ownership,
                isbn: isbn,
                coverUrl: cleanedUrl,
                status: status
            )
            
            let _ = try await createBookUseCase.execute(command: newBook)
            
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
    
}
