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
    private let readingSessionLiveActivityManager: ReadingSessionLiveActivityManagerProtocol
    
    init(
        book: Book,
        activeSession: ReadingSession? = nil,
        finishSessionUseCase: FinishReadingSessionUseCaseProtocol,
        createSessionUseCase: CreateReadingSessionUseCaseProtocol,
        deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol,
        readingSessionLiveActivityManager: ReadingSessionLiveActivityManagerProtocol
    ) {
        self.book = book
        self.endPage = book.currentPage
        self.finishSessionUseCase = finishSessionUseCase
        self.createSessionUseCase = createSessionUseCase
        self.deleteSessionUseCase = deleteSessionUseCase
        self.readingSessionLiveActivityManager = readingSessionLiveActivityManager
        
        if let session = activeSession {
            self.currentSessionId = session.id
            self.sessionStartTime = session.startTime
            self.isReading = true
            self.accumulatedTime = Date().timeIntervalSince(session.startTime)
            self.elapsedSeconds = self.accumulatedTime
        }
    }
    
    func onAppear() {
        if isReading && timerTask == nil {
            currentSprintStartTime = sessionStartTime ?? Date()
            
            readingSessionLiveActivityManager.startActivity(
                title: book.title,
                author: book.title,
                bookId: book.id,
                startTime: currentSprintStartTime!
            )
            
            startTimerLoop()
        }
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
        
        await readingSessionLiveActivityManager.endActivity()
        isLoading = false
    }
    
    func cancelSession() async {
        if self.currentSessionId != nil {
            do {
                try await deleteSessionUseCase.execute(readingSessionId: currentSessionId!)
                await readingSessionLiveActivityManager.endActivity()
            } catch {
                print("[START READING SESSION VIEW MODEL] error to delete orphan session")
            }
        }
    }
    
    private func startTimer() async {
        guard !isReading else { return }
        isReading = true
        let now = Date()
        
        if sessionStartTime == nil {
            sessionStartTime = now
            
            do {
                let command = CreateReadingSessionCommand(
                    bookId: book.id,
                    startTime: now,
                    startPage: book.currentPage,
                )
               let sessionId = try await createSessionUseCase.execute(command: command)
                self.currentSessionId = sessionId
            
                currentSprintStartTime = now
                
                readingSessionLiveActivityManager.startActivity(
                    title: book.title,
                    author: book.author,
                    bookId: book.id,
                    startTime: now
                )
                
            } catch {
                self.errorMessage = error.localizedDescription
                isReading = false
                self.sessionStartTime = nil
                return
            }
        }
        
        currentSprintStartTime = Date()
        
        await readingSessionLiveActivityManager.updateActivity(
            isReading: true,
            startTime: now,
            accumulatedTime: self.accumulatedTime
        )
        
        startTimerLoop()

    }
    
    private func pauseTimer() {
        isReading = false
        timerTask?.cancel()
        timerTask = nil
        
        if let sprintStart = currentSprintStartTime {
            accumulatedTime += Date().timeIntervalSince(sprintStart)
        }
        currentSprintStartTime = nil
        
        Task {
            await readingSessionLiveActivityManager.updateActivity(
                isReading: false,
                startTime: nil,
                accumulatedTime: accumulatedTime
            )
        }
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
