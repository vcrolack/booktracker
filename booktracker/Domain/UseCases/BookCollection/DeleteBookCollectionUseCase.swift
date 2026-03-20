//
//  DeleteBookCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol DeleteBookCollectionUseCaseProtocol {
    func execute(bookCollectionId: UUID) async throws
}

final class DeleteBookCollectionUseCase: DeleteBookCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    private let imageProcessor: ImageProcessorService
    
    private let fetchBookCollectionUseCase: FetchBookCollectionUseCaseProtocol
    
    init(
        repository: BookCollectionRepositoryProtocol,
        fetchBookCollectionUseCase: FetchBookCollectionUseCaseProtocol,
        imageProcessor: ImageProcessorService
    ) {
        self.repository = repository
        self.fetchBookCollectionUseCase = fetchBookCollectionUseCase
        self.imageProcessor = imageProcessor
    }
    
    func execute(bookCollectionId: UUID) async throws {
        guard let bookCollection = try await fetchBookCollectionUseCase.execute(bookCollectionId: bookCollectionId) else {
            throw BookCollectionDomainError.bookNotFound
        }
        
        if let fileName = bookCollection.cover {
            _ = imageProcessor.deleteImage(fileName: fileName, folderName: "CollectionCovers")
        }
        
        try await repository.delete(by: bookCollectionId)
    }
}
