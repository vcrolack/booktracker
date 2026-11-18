//
//  CallRecorder.swift
//  booktracker
//
//  Created by Victor rolack on 17-11-26.
//

import Foundation

enum RecordedCall: Equatable, Sendable {
    case fetchBook(UUID)
    case deleteBook(UUID)
    case deleteSessions(UUID)
    case removeFromCollections(UUID)
}

actor CallRecorder {
    private(set) var calls: [RecordedCall] = []
    
    func record(_ call: RecordedCall) {
        calls.append(call)
    }
}
