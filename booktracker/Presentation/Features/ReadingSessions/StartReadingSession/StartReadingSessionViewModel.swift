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
    
    var endPage: Int? = nil
    var currentSessionId: UUID?
    
    var isReading: Bool = false
    var cancelSaveSession: Bool = false
    var sessionStartTime: Date?
    var elapsedSeconds: TimeInterval = 0
    var isLoading: Bool = false
    var isRecalculatingTime: Bool = false
    var errorMessage: String? = nil
    
    private var currentSprintStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    
    @ObservationIgnored private var timerTask: Task<Void, Never>?
    
    private let finishSessionUseCase: FinishReadingSessionUseCaseProtocol
    private let createSessionUseCase: CreateReadingSessionUseCaseProtocol
    private let deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol
    private let pauseSessionUseCase: PauseReadingSessionUseCaseProtocol
    private let resumeSessionUseCase: ResumeReadingSessionUseCaseProtocol
    private let readingSessionLiveActivityManager: ReadingSessionLiveActivityManagerProtocol
    
    init(
        book: Book,
        activeSession: ReadingSession? = nil,
        finishSessionUseCase: FinishReadingSessionUseCaseProtocol,
        createSessionUseCase: CreateReadingSessionUseCaseProtocol,
        deleteSessionUseCase: DeleteReadingSessionUseCaseProtocol,
        pauseSessionUseCase: PauseReadingSessionUseCaseProtocol,
        resumeSessionUseCase: ResumeReadingSessionUseCaseProtocol,
        readingSessionLiveActivityManager: ReadingSessionLiveActivityManagerProtocol
    ) {
        self.book = book
        self.endPage = book.currentPage
        self.finishSessionUseCase = finishSessionUseCase
        self.createSessionUseCase = createSessionUseCase
        self.deleteSessionUseCase = deleteSessionUseCase
        self.pauseSessionUseCase = pauseSessionUseCase
        self.resumeSessionUseCase = resumeSessionUseCase
        self.readingSessionLiveActivityManager = readingSessionLiveActivityManager
        
        if let session = activeSession {
            let now = Date()
            self.currentSessionId = session.id
            self.sessionStartTime = session.startTime
            self.isReading = !session.isPaused
            self.accumulatedTime = session.duration(at: now)
            self.elapsedSeconds = self.accumulatedTime
            self.currentSprintStartTime = session.isPaused ? nil : now
        }
    }
    
    var isSaveButtonDisabled: Bool {
        if isLoading { return true }
        
        guard let finalPage = endPage else { return true }
        
        if finalPage == book.currentPage { return true }
        
        if finalPage < book.currentPage { return true }
        
        if finalPage > book.pages { return true }
        
        return false
    }
    
    func onAppear() {
        guard currentSessionId != nil, timerTask == nil else { return }
        
        readingSessionLiveActivityManager.startActivity(
            title: book.title,
            author: book.author,
            bookId: book.id,
            startTime: currentSprintStartTime ?? Date(),
            accumulatedTime: self.accumulatedTime
        )
        
        // La actividad pudo haberse recuperado con un estado viejo (p. ej. "Pausado"): la sincronizamos
        Task {
            await readingSessionLiveActivityManager.updateActivity(
                isReading: isReading,
                startTime: currentSprintStartTime,
                accumulatedTime: accumulatedTime
            )
        }
        
        if isReading {
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
            if endPage != nil {
                try await finishSessionUseCase.execute(id: sessionId, endPage: endPage!, endTime: Date())
            }
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
                    startTime: now,
                    accumulatedTime: 0
                )
                
            } catch {
                self.errorMessage = error.localizedDescription
                isReading = false
                self.sessionStartTime = nil
                return
            }
        } else if let sessionId = currentSessionId {
            do {
                try await resumeSessionUseCase.execute(id: sessionId, at: now)
            } catch {
                self.errorMessage = error.localizedDescription
                isReading = false
                return
            }
        }
        
        currentSprintStartTime = now
        
        await readingSessionLiveActivityManager.updateActivity(
            isReading: true,
            startTime: now,
            accumulatedTime: self.accumulatedTime
        )
        
        startTimerLoop()
        
    }
    
    private func pauseTimer() {
        let now = Date()
        isReading = false
        timerTask?.cancel()
        timerTask = nil
        
        if let sprintStart = currentSprintStartTime {
            accumulatedTime += now.timeIntervalSince(sprintStart)
        }
        currentSprintStartTime = nil
        elapsedSeconds = accumulatedTime
        
        Task {
            if let sessionId = currentSessionId {
                do {
                    try await pauseSessionUseCase.execute(id: sessionId, at: now)
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
            
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
                    if !Task.isCancelled, self.currentSprintStartTime != nil {
                        self.updateElapsedSeconds()
                        
                        // 2. 👈 ¡BINGO! Ahora sí es seguro viajar a la otra pantalla. Bajamos el flag.
                        if self.isRecalculatingTime {
                            self.isRecalculatingTime = false
                        }
                    }
                } catch {
                    break
                }
                
            }
        }
    }
    
    private func updateElapsedSeconds() {
        guard let sprintStart = currentSprintStartTime else { return }
        elapsedSeconds = accumulatedTime + Date().timeIntervalSince(sprintStart)
    }
    
    func appDidEnterBackground() {
        timerTask?.cancel()
        timerTask = nil
        
        // En pausa el tiempo no avanza, así que no hay nada que recalcular al volver
        if isReading {
            isRecalculatingTime = true
        }
    }
    
    func appWillEnterForeground() {
        if isReading {
            updateElapsedSeconds()
            startTimerLoop()
        }
        isRecalculatingTime = false
    }
}
