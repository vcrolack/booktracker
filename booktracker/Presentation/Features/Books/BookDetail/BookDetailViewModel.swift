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
    private let acquireBookForReading: AcquireBookForReadingUseCaseProtocol
    
    init(
        book: Book,
        finishReadingBookUseCase: FinishReadingBookUseCaseProtocol,
        startReadingBookUseCase: StartReadingBookUseCaseProtocol,
        abandonBookUseCase: AbandonBookUseCaseProtocol,
        acquireBookForReading: AcquireBookForReadingUseCaseProtocol
    ) {
        self.book = book
        self.finishReadingBookUseCase = finishReadingBookUseCase
        self.startReadingBookUseCase = startReadingBookUseCase
        self.abandonBookUseCase = abandonBookUseCase
        self.acquireBookForReading = acquireBookForReading
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
    
    func finishReading() async {
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
    
    func abandon() async {
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
    
    func acquireBookForReading() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await acquireBookForReading.execute(bookId: book.id, newOwnership: .owner)
            try book.acquireForReading(newOwnership: .owner)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteBook() {
        print("Deleting book... (pending cause ReadginSession implementation)")
    }
}
