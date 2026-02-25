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
    
    func makeBookRepository() -> BookRepositoryProtocol {
        return BookRepositoryImpl(localDataSource: makeBookDataSource())
    }
    
    // MARK: - 🚀 Use Cases (La Lógica de Negocio)
        
        // Aquí es donde instanciarás tus Casos de Uso pasándoles el Repositorio.
        // Ejemplo de cómo se verá cuando los conectemos:
        /*
        func makeCreateBookUseCase() -> CreateBookUseCase {
            return CreateBookUseCase(repository: makeBookRepository())
        }
        */
    
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
    
    // TODO: need ReadingSession impl
   // func makeDeleteBookUseCase() -> DeleteBookUseCaseProtocol {
   //     return DeleteBookUseCase(repository: makeBookRepository())
   // }
        
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
    func makeAddBookViewModel() -> AddBookViewModel {
        return AddBookViewModel(createBookUseCase: makeCreateBookUseCase())
    }
    
    @MainActor
    func makeBookDetailViewModel(book: Book) -> BookDetailViewModel {
        return BookDetailViewModel(
            book: book,
            finishReadingBookUseCase: makeFinishReadingBookUseCase(),
            startReadingBookUseCase: makeStartReadingBookUseCase(),
            abandonBookUseCase: makeAbandonBookUseCase(),
        )
    }
}
