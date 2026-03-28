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
    
    private let imageProcessor: ImageProcessorService
    
    private init() {
        self.imageProcessor = ImageProcessor()
        do {
            let schema = Schema([
                BookSD.self,
                ReadingSessionSD.self,
                BookCollectionSD.self,
                ReadingGoalSD.self,
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
    
    private func makeBookCollectionDataSource() -> BookCollectionLocalDataSourceProtocol {
        return BookCollectionSDDataSource(context: modelContainer.mainContext)
    }
    
    private func makeReadingGoalDataSource() -> ReadingGoalLocalDataSourceProtocol {
        return ReadingGoalSDDataSource(context: modelContainer.mainContext)
    }
    
    func makeBookRepository() -> BookRepositoryProtocol {
        return BookRepositoryImpl(localDataSource: makeBookDataSource())
    }
    
    func makeReadingSessionRepository() -> ReadingSessionRepositoryProtocol {
        return ReadingSessionRepositoryImpl(localDataSource: makeReadingSessionDataSource())
    }
    
    func makeBookCollectionRepository() -> BookCollectionRepositoryProtocol {
        return BookCollectionRepositoryImpl(localDataSource: makeBookCollectionDataSource())
    }
    
    func makeReadingGoalRepository() -> ReadingGoalRepositoryProtocol {
        return ReadingGoalRepositoryImpl(localDataSource: makeReadingGoalDataSource())
    }
    
    // MARK: - 🌍 Global State
    @MainActor
    lazy var globalSessionManager: GlobalSessionManager = {
        return GlobalSessionManager(getActiveSessionUseCase: makeGetActiveReadingSessionUseCase(), fetchBookUseCase: makeFetchBookUseCase())
    }()
    
    lazy var readingSessionLiveActivityManager: ReadingLiveActivityManager = {
        return ReadingLiveActivityManager()
    }()
    
    func makeImageProcessor() -> ImageProcessorService {
        return imageProcessor
    }
    
    func makeReadingProgressService() -> ReadingProgressService {
        return ReadingProgressService()
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
    
     func makeDeleteBookUseCase() -> DeleteBookUseCaseProtocol {
         return DeleteBookUseCase(
            repository: makeBookRepository(),
            deleteAllSessionsUseCase: makeDeleteAllReadingSessionsUseCase(),
            removeBookFromAllCollectionsUseCase: makeRemoveBookFromAllCollectionsUseCase()
         )
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
    
    func makeGetActiveReadingSessionUseCase() -> GetActiveReadingSessionUseCaseProtocol {
        return GetActiveReadingSessionUseCase(repository: makeReadingSessionRepository())
    }
    
    func makeDeleteAllReadingSessionsUseCase() -> DeleteAllReadingSessionsUseCaseProtocol {
        return DeleteAllReadingSessionsUseCase(repository: makeReadingSessionRepository())
    }
    
    func makeGetWeeklyReadingSessionsUseCase() -> GetWeeklyReadingSessionsUseCaseProtocol {
        return GetWeeklyReadingSessionsUseCase(fetchReadingSessionsUseCase: makeFetchReadingSessionsUseCase())
    }
    
    // MARK: BOOK COLLECTIONS USE CASES
    func makeRemoveBooksFromCollectionUseCase() -> RemoveBooksFromCollectionUseCaseProtocol {
        return RemoveBooksFromCollectionUseCase(
            repository: makeBookCollectionRepository()
        )
    }
    
    func makeRemoveBookFromAllCollectionsUseCase() -> RemoveBookFromAllCollectionsUseCaseProtocol {
        return RemoveBookFromAllCollectionsUseCase(repository: makeBookCollectionRepository())
    }
    
    func makeCreateBookCollectionUseCase() -> CreateBookCollectionUseCaseProtocol {
        return CreateBookCollectionUseCase(repository: makeBookCollectionRepository(), imageProcessor: makeImageProcessor())
    }
    
    func makeFetchBookCollectionsUseCase() -> FetchBookCollectionsUseCaseProtocol {
        return FetchBookCollectionsUseCase(repository: makeBookCollectionRepository())
    }
    
    func makeUpdateBookCollectionUseCase() -> UpdateBookCollectionUseCaseProtocol {
        return UpdateBookCollectionUseCase(repository: makeBookCollectionRepository(), imageProcessor: makeImageProcessor())
    }
    
    func makeFetchBookCollectionUseCase() -> FetchBookCollectionUseCaseProtocol {
        return FetchBookCollectionUseCase(repository: makeBookCollectionRepository())
    }
    
    func makeDeleteBookCollectionUseCase() -> DeleteBookCollectionUseCaseProtocol {
        return DeleteBookCollectionUseCase(
            repository: makeBookCollectionRepository(),
            fetchBookCollectionUseCase: makeFetchBookCollectionUseCase(),
            imageProcessor: makeImageProcessor())
    }
    
    // MARK: - READING GOALS USE CASES
    func makeCreateReadingGoalUseCase() -> CreateReadingGoalUseCaseProtocol {
        return CreateReadingGoalUseCase(repository: makeReadingGoalRepository())
    }
    
    // MARK: - STATS USE CASES
    func makeGetDashboardTodayStatsUseCase() -> GetDashboardTodayStatsUseCaseProtocol {
        return GetDashboardTodayStatsUseCase(
            readingGoalRepository: makeReadingGoalRepository(),
            progressService: makeReadingProgressService(),
            fetchBooksUseCase: makeFetchBooksUseCase(),
            fetchReadingSessionsUseCase: makeFetchReadingSessionsUseCase()
        )
    }
    
    func makeGetReadingHeatmapUseCase() -> GetReadingHeatmapUseCaseProtocol {
        return GetReadingHeatmapUseCase(fetchSessionsUseCase: makeFetchReadingSessionsUseCase())
    }
    
    func makeGetMonthlyEffortUseCase() -> GetMonthlyEffortUseCaseProtocol {
        return GetMonthlyEffortUseCase(fetchSessionsUseCase: makeFetchReadingSessionsUseCase())
    }
    
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
            deleteBookUseCase: makeDeleteBookUseCase()
        )
    }
    
    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            fetchBooksUseCase: makeFetchBooksUseCase(),
            getActiveSessionUseCase: makeGetActiveReadingSessionUseCase(),
            fetchReadingSessionsUseCase: makeFetchReadingSessionsUseCase(),
            fetchBookCollectionsUseCase: makeFetchBookCollectionsUseCase(),
            readingStatisticsService: ReadingStatisticsService(),
            libraryStatisticsService: LibraryStatisticsService(),
        )
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
        activeSession: ReadingSession? = nil,
        finishSessionUseCase: FinishReadingSessionUseCaseProtocol,
        createSessionUseCase: CreateReadingSessionUseCaseProtocol,
        deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol
    ) -> StartReadingSessionViewModel {
        return StartReadingSessionViewModel(
            book: book,
            activeSession: activeSession,
            finishSessionUseCase: finishSessionUseCase,
            createSessionUseCase: createSessionUseCase,
            deleteSessionUseCase: deleteSessionUseCase,
            readingSessionLiveActivityManager: readingSessionLiveActivityManager
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
    
    @MainActor
    func makeBookCollectionFormViewModel(collectionToEdit: BookCollection? = nil) -> BookCollectionFormViewModel {
        return BookCollectionFormViewModel(
            createBookCollectionUseCase: makeCreateBookCollectionUseCase(),
            collectionToEdit: collectionToEdit,
            updateBookCollectionUseCase: makeUpdateBookCollectionUseCase(),
            deleteBookCollectionUseCase: makeDeleteBookCollectionUseCase(),
            imageProcessor: makeImageProcessor()
        )
    }
    
    @MainActor
    func makeBookCollectionListViewModel() -> BookCollectionListViewModel {
        return BookCollectionListViewModel(fetchBookCollectionsUseCase: makeFetchBookCollectionsUseCase())
    }
    
    
    @MainActor
    func makeBookCollectionDetailViewModel(bookCollection: BookCollection) -> BookCollectionDetailViewModel {
        return BookCollectionDetailViewModel(
            bookCollection: bookCollection,
            fetchBooksUseCase: makeFetchBooksUseCase(),
            updateBookCollectionUseCase: makeUpdateBookCollectionUseCase(),
            fetchBookCollectionUseCase: makeFetchBookCollectionUseCase()
        )
    }
    
    @MainActor
    func makeBookSelectionViewModel(initialSelectedIds: Set<UUID>) -> BookSelectionViewModel {
        return BookSelectionViewModel(initialSelectedIds: initialSelectedIds, fetchBooksUseCase: makeFetchBooksUseCase())
    }
    
    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(imageProcessor: makeImageProcessor())
    }
    
    @MainActor
    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            getTodayStats: makeGetDashboardTodayStatsUseCase(),
            getMonthlyEffort: makeGetMonthlyEffortUseCase(),
            getReadingHeatmap: makeGetReadingHeatmapUseCase(),
            getWeeklyReadingSessions: makeGetWeeklyReadingSessionsUseCase()
        )
    }
    
    @MainActor
    func makeReadingGoalFormViewModel() -> ReadingGoalFormViewModel {
        return ReadingGoalFormViewModel(createGoalUseCase: makeCreateReadingGoalUseCase())
    }
}
