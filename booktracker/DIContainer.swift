//
//  DIContainer.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import SwiftData

@MainActor
final class DIContainer {
    let modelContainer: ModelContainer
    
    static let shared = DIContainer()
    
    private init() {
        do {
            let schema = Schema([
                BookSD.self,
                ReadingSessionSD.self,
            ])
            
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("🔥 Error crítico: No se pudo inicializar SwiftData: \(error)")
        }
    }
    
    private func makeBookDataSource() -> BookLocalDataSourceProtocol {
        return BookSDDataSource(context: modelContainer.mainContext)
    }
    
    private func makeReadingSessionDataSource() -> ReadingSessionLocalDataSourceProtocol {
        return ReadingSessionSDDataSource(context: modelContainer.mainContext)
    }
    
    func makeBookRepository() -> BookRepositoryProtocol {
        return BookRepositoryImpl(localDataSource: makeBookDataSource())
    }
    
    func makeReadingSessionRepository() -> ReadingSessionRepositoryProtocol {
        return ReadingSessionRepositoryImpl(localDataSource: makeReadingSessionDataSource())
    }
    
    // MARK: - 🚀 Use Cases (La Lógica de Negocio)
        
        // Aquí es donde instanciarás tus Casos de Uso pasándoles el Repositorio.
        // Ejemplo de cómo se verá cuando los conectemos:
        /*
        func makeCreateBookUseCase() -> CreateBookUseCase {
            return CreateBookUseCase(repository: makeBookRepository())
        }
        */
    
    // MARK: - BOOKS USE CASES
    func makeCreateBookUseCase() -> CreateBookUseCaseProtocol {
        return CreateBookUseCase(repository: makeBookRepository())
    }
    
    func makeFinishReadingBookUseCase() -> FinishReadingBookUseCaseProtocol {
        return FinishReadingBookUseCase(repository: makeBookRepository())
    }
    
    func makeStartReadingBookUseCase() -> StartReadingBookUseCaseProtocol {
        return StartReadingBookUseCase(repository: makeBookRepository())
    }
    
    func makeAbandonBookUseCase() -> AbandonBookUseCaseProtocol {
        return AbandonBookUseCase(repository: makeBookRepository())
    }
    
    func makeAcquireBookForReadingUseCase() -> AcquireBookForReadingUseCaseProtocol {
        return AcquireBookForReadingUseCase(repository: makeBookRepository())
    }
    
    func makeUpdateBookDetailsUseCase() -> UpdateBookDetailsUseCaseProtocol {
        return UpdateBookDetailsUseCase(repository: makeBookRepository())
    }
    
    func makeFetchBookUseCase() -> FetchBookUseCaseProtocol {
        return FetchBookUseCase(repository: makeBookRepository())
    }
    
    func makeFetchBooksUseCase() -> FetchBooksUseCaseProtocol {
        return FetchBooksUseCase(repository: makeBookRepository())
    }
    
    func makeUpdateBookProgressUseCase() -> UpdateBookProgressUseCaseProtocol {
        return UpdateBookProgressUseCase(repository: makeBookRepository())
    }
    
    func makeSearchExternalBooksUseCase() -> SearchExternalBooksUseCaseProtocol {
        return SearchExternalBooksUseCase(provider: makeExternalBookProvider())
    }
    
    // MARK: READING SESSIONS USE CASES
    func makeCreateReadingSessionUseCase() -> CreateReadingSessionUseCaseProtocol {
        return CreateReadingSessionUseCase(repository: makeReadingSessionRepository(), bookRepository: makeBookRepository())
    }
    
    func makeFinishReadingSessionUseCase() -> FinishReadingSessionUseCaseProtocol {
        return FinishReadingSessionUseCase(repository: makeReadingSessionRepository(), updatedBookProgressUseCase: makeUpdateBookProgressUseCase())
    }
    
    func makeFetchReadingSessionsUseCase() -> FetchReadingSessionsUseCaseProtocol {
        return FetchReadingSessionsUseCase(repository: makeReadingSessionRepository())
    }
    
    func makeDeleteReadingSessionUseCase() -> DeleteReadingSessionUseCaseProtocol {
        return DeleteReadingSessionUseCase(repository: makeReadingSessionRepository(), updateBookProgressUseCase: makeUpdateBookProgressUseCase())
    }
    
    // TODO: need ReadingSession impl
   // func makeDeleteBookUseCase() -> DeleteBookUseCaseProtocol {
   //     return DeleteBookUseCase(repository: makeBookRepository())
   // }
    
    // MARK: - 🌐 Providers (Capa de Datos Externa)
    func makeExternalBookProvider() -> ExternalBookProviderProtocol {
        return GoogleBooksProvider()
    }
        
        // MARK: - 📱 ViewModels (La Presentación)
        
        // Las pantallas de SwiftUI le pedirán sus ViewModels a este contenedor
        /*
        func makeBookListViewModel() -> BookListViewModel {
            return BookListViewModel(
                fetchBooksUseCase: makeFetchBooksUseCase(),
                deleteBookUseCase: makeDeleteBookUseCase()
            )
        }
        */
    
    @MainActor
    func makeBookListViewModel() -> BookListViewModel {
        return BookListViewModel(repository: makeBookRepository())
    }
    
    @MainActor
    func makeBookFormViewModel(book: Book? = nil) -> BookFormViewModel {
        return BookFormViewModel(
            book: book,
            createBookUseCase: makeCreateBookUseCase(),
            updateBookDetailsUseCase: makeUpdateBookDetailsUseCase()
        )
    }
    
    @MainActor
    func makeBookDetailViewModel(book: Book) -> BookDetailViewModel {
        return BookDetailViewModel(
            book: book,
            finishReadingBookUseCase: makeFinishReadingBookUseCase(),
            startReadingBookUseCase: makeStartReadingBookUseCase(),
            abandonBookUseCase: makeAbandonBookUseCase(),
            acquireBookForReading: makeAcquireBookForReadingUseCase(),
            fetchBookUseCase: makeFetchBookUseCase(),
        )
    }
    
    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(fetchBooksUseCase: makeFetchBooksUseCase())
    }
    
    @MainActor
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            searchUseCase: makeSearchExternalBooksUseCase(),
            createBookUseCase: makeCreateBookUseCase(),
            fetchBooksUseCase: makeFetchBooksUseCase(),
        )
    }
    
    @MainActor
    func makeStartReadingSessionViewModel(
        book: Book,
        finishSessionUseCase: FinishReadingSessionUseCaseProtocol,
        createSessionUseCase: CreateReadingSessionUseCaseProtocol,
        deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol
    ) -> StartReadingSessionViewModel {
        return StartReadingSessionViewModel(
            book: book,
            finishSessionUseCase: finishSessionUseCase,
            createSessionUseCase: createSessionUseCase,
            deleteSessionUseCase: deleteSessionUseCase
        )
    }
    
    @MainActor
    func makeBookSessionsViewModel(bookId: UUID) -> BookSessionsViewModel {
        return BookSessionsViewModel(
            bookId: bookId,
            fetchSessionsUseCase: makeFetchReadingSessionsUseCase(),
            readingStatisticsService: ReadingStatisticsService()
        )
    }
}
