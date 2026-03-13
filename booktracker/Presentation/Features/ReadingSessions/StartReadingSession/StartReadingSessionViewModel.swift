//
//  StartReadingSessionViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
final class StartReadingSessionViewModel {
    var book: Book
    
    var endPage: Int
    var currentSessionId: UUID?
    
    var isReading: Bool = false
    var cancelSaveSession: Bool = false
    var sessionStartTime: Date?
    var elapsedSeconds: TimeInterval = 0
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private var currentSprintStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    
    @ObservationIgnored private var timerTask: Task<Void, Never>?
    
    private let finishSessionUseCase: FinishReadingSessionUseCaseProtocol
    private let createSessionUseCase: CreateReadingSessionUseCaseProtocol
    private let deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol
    
    init(
        book: Book,
        finishSessionUseCase: FinishReadingSessionUseCaseProtocol,
        createSessionUseCase: CreateReadingSessionUseCaseProtocol,
        deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol
    ) {
        self.book = book
        self.endPage = book.currentPage
        self.finishSessionUseCase = finishSessionUseCase
        self.createSessionUseCase = createSessionUseCase
        self.deleteSessionUseCase = deleteSessionUseCase
    }
    
    func toggleSession() {
        if isReading {
            pauseTimer()
        } else {
            Task { await startTimer() }
        }
    }
    
    func finishSession() async throws {
        guard let sessionId = currentSessionId else { return }
        isLoading = true
        
        do {
            try await finishSessionUseCase.execute(id: sessionId, endPage: endPage, endTime: Date())
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func cancelSession() async {
        if self.currentSessionId != nil {
            do {
                try await deleteSessionUseCase.execute(readingSessionId: currentSessionId!)
            } catch {
                print("[START READING SESSION VIEW MODEL] error to delete orphan session")
            }
        }
    }
    
    private func startTimer() async {
        guard !isReading else { return }
        isReading = true
        
        if sessionStartTime == nil {
            let startTime = Date()
            sessionStartTime = startTime
            
            do {
                let command = CreateReadingSessionCommand(
                    bookId: book.id,
                    startTime: startTime,
                    startPage: book.currentPage,
                )
               let sessionId = try await createSessionUseCase.execute(command: command)
                self.currentSessionId = sessionId
            } catch {
                self.errorMessage = error.localizedDescription
                isReading = false
                self.sessionStartTime = nil
                return
            }
        }
        
        currentSprintStartTime = Date()
        startTimerLoop()

    }
    
    private func pauseTimer() {
        isReading = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func startTimerLoop() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(1))
                    if !Task.isCancelled, let sprintStart = self.currentSprintStartTime {
                        self.elapsedSeconds = self.accumulatedTime + Date().timeIntervalSince(sprintStart)
                    }
                } catch {
                    break
                }

            }
        }
    }
    
    func appDidEnterBackground() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    func appWillEnterForeground() {
        if isReading {
            startTimerLoop()
        }
    }
}
