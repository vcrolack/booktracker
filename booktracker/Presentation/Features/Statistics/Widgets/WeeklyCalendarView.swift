//
//  WeeklyCalendarView.swift
//  booktracker
//
//  Created by Victor rolack on 27-03-26.
//

import SwiftUI

struct WeeklyCalendarView: View {
    let sessions: [ReadingSession]
    
    private let calendar = Calendar.current
    private let days = Calendar.current.daysOfWeek(containing: Date())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Esta semana")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    let hasRead = hasSession(on: day)
                    let isToday = calendar.isDateInToday(day)
                    
                    VStack(spacing: 8) {
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .fontWeight(isToday ? .bold : .regular)
                            .foregroundStyle(isToday ? .primary : .secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(hasRead ? Color.orange : Color.gray.opacity((0.15)))
                                .frame(width: 25, height: 25)
                            
                            if hasRead {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isToday ? Color.orange : Color.clear, lineWidth: 2)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func hasSession(on date: Date) -> Bool {
        sessions.contains { guard let endTime = $0.endTime else { return false }; return calendar.isDate(endTime, inSameDayAs: date) }
    }
}

#Preview {
    WeeklyCalendarView(sessions: [])
}
