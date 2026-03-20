//
//  HomeViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 06-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
class HomeViewModel {
    private var allBooks: [Book] = []
    private var allSessions: [ReadingSession] = []
    
    var readingQuickStats: ReadingStats?
    var libraryQuickStats: LibraryStats?
    var topCollections: [BookCollection] = []

    var showingActiveSessionSheet: Bool = false

    var currentReadingBooks: [Book] {
        allBooks
            .filter { $0.status == .reading }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
            .map { $0 }
    }
    
    var upNextBooks: [Book] {
        allBooks
            .filter { $0.status == .toRead }
            .prefix(5)
            .map { $0 }
    }
    
    var recentlyFinishedBooks: [Book] {
        allBooks
            .filter { $0.status == .finalized }
            .sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
            .prefix(3)
            .map { $0 }
    }
    
    private var showingAddBookForm: Bool = false
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol
    private let fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    private let fetchBookCollectionsUseCase: FetchBookCollectionsUseCaseProtocol
    private let readingStatisticsService: ReadingStatisticsServiceProtocol
    private let libraryStatisticsService: LibraryStatisticsServiceProtocol
    
    init(
        fetchBooksUseCase: FetchBooksUseCaseProtocol,
        getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol,
        fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol,
        fetchBookCollectionsUseCase: FetchBookCollectionsUseCaseProtocol,
        readingStatisticsService: ReadingStatisticsServiceProtocol,
        libraryStatisticsService: LibraryStatisticsServiceProtocol,
    ) {
        self.fetchBooksUseCase = fetchBooksUseCase
        self.getActiveSessionUseCase = getActiveSessionUseCase
        self.fetchReadingSessionsUseCase = fetchReadingSessionsUseCase
        self.fetchBookCollectionsUseCase = fetchBookCollectionsUseCase
        self.readingStatisticsService = readingStatisticsService
        self.libraryStatisticsService = libraryStatisticsService
    }
    
    func loadDashboard() async {
        do {
            async let booksTask = fetchBooksUseCase.execute(filter: nil)
            async let readingSessionsTask = fetchReadingSessionsUseCase.execute(filter: nil)
            async let bookCollectionsTask = fetchBookCollectionsUseCase.execute(filter: nil)
            
            self.allBooks = try await booksTask
            self.allSessions = try await readingSessionsTask
            let bookCollections = try await bookCollectionsTask
            self.topCollections = Array(bookCollections.prefix(5))
            
            updateAllStats()
        } catch {
            print("Error cargando dashboard: \(error.localizedDescription)")
        }
    }
    
    func updateAllStats() {
        readingQuickStats = readingStatisticsService.calculateStats(from: allSessions)
        libraryQuickStats = libraryStatisticsService.calculateStats(from: allBooks)
    }
}
