//
//  BookDetailViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 25-02-26.
//

import Foundation
import Observation

@MainActor
@Observable
class BookDetailViewModel {
    var book: Book
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let finishReadingBookUseCase: FinishReadingBookUseCaseProtocol
    private let startReadingBookUseCase: StartReadingBookUseCaseProtocol
    private let abandonBookUseCase: AbandonBookUseCaseProtocol
    
    init(
        book: Book,
        finishReadingBookUseCase: FinishReadingBookUseCaseProtocol,
        startReadingBookUseCase: StartReadingBookUseCaseProtocol,
        abandonBookUseCase: AbandonBookUseCaseProtocol
    ) {
        self.book = book
        self.finishReadingBookUseCase = finishReadingBookUseCase
        self.startReadingBookUseCase = startReadingBookUseCase
        self.abandonBookUseCase = abandonBookUseCase
    }
    
    // MARK: - Actions
    
    func startReading() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await startReadingBookUseCase.execute(bookId: book.id)
            try book.startReading(at: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func finishReading() async throws {
        isLoading = true
        errorMessage = nil
        do {
            try await finishReadingBookUseCase.execute(command: FinishReadingBookCommand(bookId: book.id))
            try book.finishReading(at: Date(), rating: nil, review: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func abandon() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let reason = "Yes, I'm leaving..."
            try await abandonBookUseCase.execute(bookId: book.id, reason: "Yes, I'm leaving...")
            try book.abandon(reason: reason, at: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteBook() {
        print("Deleting book... (pending cause ReadginSession implementation)")
    }
}
