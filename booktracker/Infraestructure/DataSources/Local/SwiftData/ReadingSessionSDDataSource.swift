//
//  ReadingSessionSDDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

import Foundation
import SwiftData

protocol ReadingSessionLocalDataSourceProtocol {
    func save(session: ReadingSession) throws
    func fetchReadingSession(by id: UUID) throws -> ReadingSession?
    func fetchReadingSessions(matching filter: ReadingSessionFilter?) throws -> [ReadingSession]
    func deleteReadingSession(by id: UUID) throws
    func deleteAllReadingSessions(for bookId: UUID) throws
}

final class ReadingSessionSDDataSource: ReadingSessionLocalDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save(session: ReadingSession) throws {
        do {
            let sessionId = session.id
            
            var descriptor = FetchDescriptor<ReadingSessionSD>(predicate: #Predicate {$0.id == sessionId })
            descriptor.fetchLimit = 1
            
            if let existingSession = try context.fetch(descriptor).first {
                existingSession.startTime = session.startTime
                existingSession.endTime = session.endTime
                existingSession.startPage = session.startPage
                existingSession.endPage = session.endPage
            } else {
                let newSession = ReadingSessionMapper.toDataModel(from: session)
                context.insert(newSession)
            }
            
            try context.save()
            
        } catch {
            throw DataSourceError.saveFailed(error.localizedDescription)
        }
    }
    
    func fetchReadingSession(by id: UUID) throws -> ReadingSession? {
        do {
            let sessionId = id
            var descriptor = FetchDescriptor<ReadingSessionSD>(
                predicate: #Predicate { $0.id == sessionId }
            )
            
            descriptor.fetchLimit = 1
            
            guard let sessionSD = try context.fetch(descriptor).first else {
                return nil
            }
            
            return ReadingSessionMapper.toDomain(from: sessionSD)
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    func fetchReadingSessions(matching filter: ReadingSessionFilter? = nil) throws -> [ReadingSession] {
        do {
            var sortDescriptors: [SortDescriptor<ReadingSessionSD>] = []
            let activeSort = filter?.sortBy ?? .endTimeDescending
            
            switch activeSort {
            case .endPageDescending:
                sortDescriptors.append(SortDescriptor(\.endPage, order: .reverse))
            case .startTimeAscending:
                sortDescriptors.append(SortDescriptor(\.startTime, order: .forward))
            case .startTimeDescending:
                sortDescriptors.append(SortDescriptor(\.startTime, order: .reverse))
            case .endPageAscending:
                sortDescriptors.append(SortDescriptor(\.endPage, order: .forward))
            case .endTimeDescending:
                sortDescriptors.append(SortDescriptor(\.endTime, order: .reverse))
            case .endTimeAscending:
                sortDescriptors.append(SortDescriptor(\.endTime, order: .forward))
            }
            
            var descriptor = FetchDescriptor<ReadingSessionSD>(sortBy: sortDescriptors)
            
            if let byBook = filter?.bookId {
                descriptor.predicate = #Predicate { $0.bookId == byBook }
            }
            
            let fetchedModels = try context.fetch(descriptor)
            
            return fetchedModels.map { ReadingSessionMapper.toDomain(from: $0) }
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    // TODO: IF YOU DELETE A SESSION, HOY IMPACTS YOUR METRICS?
    func deleteReadingSession(by id: UUID) throws {
        do {
            let sessionId = id
            let descriptor = FetchDescriptor<ReadingSessionSD>(predicate: #Predicate { $0.id == sessionId })
            
            if let session = try context.fetch(descriptor).first {
                context.delete(session)
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
    
    func deleteAllReadingSessions(for bookId: UUID) throws {
        do {
            let targetBookId = bookId
            
            let descriptor = FetchDescriptor<ReadingSessionSD>(
                predicate: #Predicate { $0.bookId == targetBookId }
            )
            
            let sessionsToDelete = try context.fetch(descriptor)
            
            for session in sessionsToDelete {
                context.delete(session)
            }
            
            if !sessionsToDelete.isEmpty {
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
}
