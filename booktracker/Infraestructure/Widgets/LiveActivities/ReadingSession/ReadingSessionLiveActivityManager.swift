//
//  ReadingLiveActivityManager.swift
//  booktracker
//
//  Created by Victor rolack on 14-03-26.
//

import Foundation
import ActivityKit

protocol ReadingSessionLiveActivityManagerProtocol {
    func startActivity(title: String, author: String, bookId: UUID, startTime: Date, accumulatedTime: TimeInterval)
    func updateActivity(isReading: Bool, startTime: Date?, accumulatedTime: TimeInterval) async
    func endActivity() async
}

final class ReadingLiveActivityManager: ReadingSessionLiveActivityManagerProtocol {
    private var currentActivity: Activity<ReadingSessionAttributes>?
    
    func startActivity(title: String, author: String, bookId: UUID, startTime: Date, accumulatedTime: TimeInterval = 0) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LIVE ACTIVITY] Use has not enabled live activities")
            return
        }
        
        let existingActivities = Activity<ReadingSessionAttributes>.activities
        
        if let activityForThisBook = existingActivities.first(where: { $0.attributes.bookId == bookId }) {
            self.currentActivity = activityForThisBook
            print("[LIVE ACTIVITY] Existing activite recovered. Ignoring create another one")
            return
        }
        
        for orphanedActivity in existingActivities {
            Task { await orphanedActivity.end(nil, dismissalPolicy: .immediate) }
        }
        
        if currentActivity != nil {
            Task { await endActivity()}
        }
        
        let attributes = ReadingSessionAttributes(bookTitle: title, author: author, bookId: bookId)
        let initialState = ReadingSessionAttributes.ContentState(
            isReading: true,
            currentSprintStartTime: startTime,
            accumulatedTime: accumulatedTime
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("[LIVE ACTIVITY] Started successful. ID \(currentActivity?.id ?? "")")
        } catch {
            print("[LIVE ACTIVITY] Failed to start activity: \(error.localizedDescription)")
        }
    }
    
    func updateActivity(isReading: Bool, startTime: Date?, accumulatedTime: TimeInterval) async {
        guard let activity = currentActivity else { return }
        
        let newState = ReadingSessionAttributes.ContentState(
            isReading: isReading,
            currentSprintStartTime: startTime,
            accumulatedTime: accumulatedTime
        )
        
        let content = ActivityContent(state: newState, staleDate: nil)
        await activity.update(content)
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        
        let finalState = ReadingSessionAttributes.ContentState(
            isReading: false,
            currentSprintStartTime: nil,
            accumulatedTime: 0
        )
        
        let content = ActivityContent(state: finalState, staleDate: nil)
        await activity.end(content, dismissalPolicy: .immediate)
        currentActivity = nil
    }
}
