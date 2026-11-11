//
//  ResumeReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 10-11-26.
//

import Foundation

protocol ResumeReadingSessionUseCaseProtocol {
    func execute(id: UUID, at date: Date) async throws
}

final class ResumeReadingSessionUseCase: ResumeReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol

    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID, at date: Date) async throws {
        guard var session = try await repository.fetchSession(by: id) else {
            throw ReadingSessionDomainError.notFound
        }

        try session.resume(at: date)

        try await repository.save(session: session)
    }
}
