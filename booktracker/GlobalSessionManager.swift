//
//  Untitled.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GlobalSessionManager {
    var activeSession: ReadingSession? = nil
    var activeBook: Book? = nil
    var isSessionActive: Bool = false
    
    var isSessionSheetPresented: Bool = false
    
    private let getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol
    
    private let fetchBookUseCase: FetchBookUseCaseProtocol
    
    init(getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol, fetchBookUseCase: FetchBookUseCaseProtocol) {
        self.getActiveSessionUseCase = getActiveSessionUseCase
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    func checkActiveSession() async {
        do {
            if let session = try await getActiveSessionUseCase.execute() {
                let book = try await fetchBookUseCase.execute(bookId: session.bookId)
                self.activeSession = session
                self.activeBook = book
                self.isSessionActive = true
            } else {
                clearSessionState()
            }
        } catch {
            print("[GLOBAL SESSION MANAGER] Error fetching active session: \(error)")
            clearSessionState()
        }
    }
    
    func clearSessionState() {
        self.isSessionActive = false
        self.activeSession = nil
        self.activeBook = nil
        self.isSessionSheetPresented = false
    }
}
