//
//  DeleteBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class DeleteBookUseCase: DeleteBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    private let deleteAllSessionsUseCase: DeleteAllReadingSessionsUseCaseProtocol
    private let removeBookFromAllCollectionsUseCase: RemoveBookFromAllCollectionsUseCaseProtocol
    
    init(repository: BookRepositoryProtocol, deleteAllSessionsUseCase: DeleteAllReadingSessionsUseCaseProtocol, removeBookFromAllCollectionsUseCase: RemoveBookFromAllCollectionsUseCaseProtocol) {
        self.repository = repository
        self.deleteAllSessionsUseCase = deleteAllSessionsUseCase
        self.removeBookFromAllCollectionsUseCase = removeBookFromAllCollectionsUseCase
    }
    
    func execute(bookId: UUID) async throws {
        guard let _ = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try await deleteAllSessionsUseCase.execute(bookId: bookId)
        try await removeBookFromAllCollectionsUseCase.execute(bookId: bookId)
        
        try await repository.delete(bookId: bookId)
    }
}
