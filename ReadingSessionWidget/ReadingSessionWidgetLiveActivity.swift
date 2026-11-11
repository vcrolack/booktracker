//
//  ReadingSessionWidgetLiveActivity.swift
//  ReadingSessionWidget
//
//  Created by Victor rolack on 14-03-26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ReadingSessionWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingSessionAttributes.self) { context in
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("Leyendo: \(context.attributes.bookTitle)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                
                if context.state.isReading {
                    sessionTimer(for: context.state)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 50, alignment: .trailing)
                } else {
                    VStack(alignment: .trailing, spacing: 0) {
                        sessionTimer(for: context.state)
                            .font(.headline)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                        Text("Pausado")
                            .font(.caption2)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: 70, alignment: .trailing)
                }
            }
            .padding()
            .activityBackgroundTint(Color(UIColor.systemBackground).opacity(0.6))
            .activitySystemActionForegroundColor(Color.white)
            .widgetURL(URL(string: "booktracker://activeSession"))
            
        } dynamicIsland: { context in
            // 2. 🏝️ LA ISLA DINÁMICA (Dynamic Island)
            DynamicIsland {
                // 2A. EXPANDIDA (Cuando el usuario mantiene pulsada la isla)
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .center, spacing: 4) {
                        
                        // Icono y Texto de Estado
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text("Leyendo ahora")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .textCase(.uppercase)
                        }
                        
                        // Columna Central del Libro (image_14.png)
                        VStack(alignment: .center, spacing: 4) {
                            Text(context.attributes.bookTitle)
                                .font(.headline)
                                .lineLimit(1)
                                .padding(.horizontal)
                            
                            Text(context.attributes.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        // Cronómetro Azul y visible
                        if context.state.isReading {
                            sessionTimer(for: context.state)
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(.blue)
                                .monospacedDigit()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(spacing: 0) {
                                sessionTimer(for: context.state)
                                    .font(.title3)
                                    .monospacedDigit()
                                    .multilineTextAlignment(.center)
                                Text("Pausado")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.top, 16)
                }
            } compactLeading: {
                Image(systemName: "book.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } compactTrailing: {
                // 2C. COMPACTA DERECHA (El tiempo corriendo)
                if context.state.isReading {
                    sessionTimer(for: context.state)
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundColor(.blue)
                        .frame(maxWidth: 30, alignment: .trailing)
                } else {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.gray)
                }
            } minimal: {
                // 2D. MINIMALISTA (Cuando hay otra app usando la isla al mismo tiempo)
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
            }
            .widgetURL(URL(string: "booktracker://activeSession"))
        }
    }
    
    private func sessionTimer(for state: ReadingSessionAttributes.ContentState) -> Text {
        Text(
            timerInterval: state.timerStartDate...Date.distantFuture,
            pauseTime: state.timerPauseDate,
            countsDown: false
        )
    }
}

#Preview("Notification", as: .content, using: ReadingSessionAttributes(bookTitle: "Sample Book", author: "Author", bookId: UUID())) {
   ReadingSessionWidgetLiveActivity()
} contentStates: {
    ReadingSessionAttributes.ContentState(isReading: true, currentSprintStartTime: .now, accumulatedTime: 754)
    ReadingSessionAttributes.ContentState(isReading: false, currentSprintStartTime: nil, accumulatedTime: 300)
}
