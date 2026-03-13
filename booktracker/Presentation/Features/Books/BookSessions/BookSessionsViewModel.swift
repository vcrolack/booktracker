//
//  BookSessionsViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 12-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
final class BookSessionsViewModel {
    var sessions: [ReadingSession] = []
    var stats: ReadingStats?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let bookId: UUID
    private let fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    private let readingStatisticsService: ReadingStatisticsService
    
    init(
        bookId: UUID,
        fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol,
        readingStatisticsService: ReadingStatisticsService
    ) {
        self.bookId = bookId
        self.fetchSessionsUseCase = fetchSessionsUseCase
        self.readingStatisticsService = readingStatisticsService
    }
    
    @MainActor
    func loadSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedSessions = try await fetchSessionsUseCase.execute(filter: ReadingSessionFilter(bookId: bookId))
            
            self.sessions = fetchedSessions.sorted { $0.startTime > $1.startTime }
            
            self.stats = readingStatisticsService.calculateStats(from: self.sessions)
        } catch {
            self.errorMessage = "No pudimos cargar tu historial de lectura. Inténtalo más tarde."
        }
        
        isLoading = false
    }
}
