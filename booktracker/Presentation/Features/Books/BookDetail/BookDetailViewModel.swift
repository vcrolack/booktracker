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
    var showingFinishSheet: Bool = false
    var showingAbandonAlert: Bool = false
    
    var tempRating: Int = 5
    var tempReview: String = ""
    var tempAbandonReason: String = ""
    
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
    
    func confirmFinishReading() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let doubleRating = Double(tempRating)
            let reviewToSave = tempReview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tempReview
            
            try await finishReadingBookUseCase.execute(
                command: FinishReadingBookCommand(bookId: book.id, rating: doubleRating, review: reviewToSave)
            )
            try book.finishReading(at: Date(), rating: doubleRating, review: reviewToSave)
            
            tempReview = ""
            tempRating = 5
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func confirmAbandone() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let reasonToSave = tempAbandonReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tempAbandonReason
            
            try await abandonBookUseCase.execute(bookId: book.id, reason: reasonToSave)
            try book.abandon(reason: reasonToSave, at: Date())
            
            tempAbandonReason = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteBook() {
        print("Deleting book... (pending cause ReadginSession implementation)")
    }
}
