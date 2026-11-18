//
//  MockDeleteAllReadingSessionsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-11-26.
//
import Foundation
import Testing
@testable import booktracker

actor MockDeleteAllReadingSessionsUseCase: DeleteAllReadingSessionsUseCaseProtocol {
    private let recorder: CallRecorder
    private let error: (any Error)?
    
    init(recorder: CallRecorder, error: (any Error)? = nil) {
        self.recorder = recorder
        self.error = error
    }
    
    func execute(bookId: UUID) async throws {
        await recorder.record(.deleteSessions(bookId))
        if let error { throw error }
    }
}
