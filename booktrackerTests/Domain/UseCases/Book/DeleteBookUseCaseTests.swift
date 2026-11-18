//
//  DeleteBookUseCaseTests.swift
//  booktracker
//
//  Created by Victor rolack on 17-11-26.
//

import Foundation
import Testing
@testable import booktracker

@Suite("DeleteBookUseCase")
struct DeleteBookUseCaseTests {
    let bookId = UUID()
    
    private func makeSUT(
        bookExists: Bool = true,
        sessionsError: (any Error)? = nil,
        collectionsError: (any Error)? = nil,
        deleteError: (any Error)? = nil
    ) throws -> (sut: DeleteBookUseCase, recorder: CallRecorder) {
        let recorder = CallRecorder()
        let books = bookExists ? [try Book.fixture(id: bookId)] : []
        
        let sut = DeleteBookUseCase(
            repository: MockBookRepository(books: books, deleteError: deleteError, recorder: recorder),
            deleteAllSessionsUseCase: MockDeleteAllReadingSessionsUseCase(recorder: recorder, error: sessionsError),
            removeBookFromAllCollectionsUseCase: MockRemoveBookFromAllCollectionsUseCase(recorder: recorder, error: collectionsError)
        )
        
        return (sut, recorder)
    }
    
    @Test("Clear dependencies and delete the book, in that way")
    func deletesEverythingInOrder() async throws {
        let (sut, recorder) = try makeSUT()
        
        try await sut.execute(bookId: bookId)
        
        #expect(await recorder.calls == [
            .fetchBook(bookId),
            .deleteSessions(bookId),
            .removeFromCollections(bookId),
            .deleteBook(bookId)
        ])
    }
    
    @Test("If book does not exist, throw notFound error and not deleting nothing")
    func bookNotFoundDeletesNothing() async throws {
        let (sut, recorder) = try makeSUT(bookExists: false)
        
        await #expect(throws: RepositoryError.notFound) {
            try await sut.execute(bookId: bookId)
        }
        
        #expect(await recorder.calls == [.fetchBook(bookId)])
    }
    
    @Test("If delete sessions fails, propagate the error and stop the execution")
    func sessionsFailureStopsExecution() async throws {
        let (sut, recorder) = try makeSUT(sessionsError: DataSourceError.deleteFailed("Booom!"))
        
        await #expect(throws: DataSourceError.self) {
            try await sut.execute(bookId: bookId)
        }
        
        #expect(await recorder.calls == [
            .fetchBook(bookId),
            .deleteSessions(bookId)
        ])
    }
}
