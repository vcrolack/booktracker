//
//  ReadingSessionMapper.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

enum ReadingSessionMapper {
    static func toDataModel(from domain: ReadingSession) -> ReadingSessionSD {
        return ReadingSessionSD(
            id: domain.id,
            bookId: domain.bookId,
            startTime: domain.startTime,
            endTime: domain.endTime,
            startPage: domain.startPage,
            endPage: domain.endPage
        )
    }
    
    static func toDomain(from sdModel: ReadingSessionSD) -> ReadingSession {
        return ReadingSession(
            reconstituting: sdModel.id,
            bookId: sdModel.bookId,
            startTime: sdModel.startTime,
            endTime: sdModel.endTime,
            startPage: sdModel.startPage,
            endPage: sdModel.endPage
        )
    }
}
