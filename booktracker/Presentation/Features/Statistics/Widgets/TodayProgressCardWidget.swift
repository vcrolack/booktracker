//
//  TodayProgressCard.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI

struct TodayProgressCardWidget: View {
    let stats: ReadingProgressStats
    let currentDay = Date.now
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Lectura de Hoy \(currentDate())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(stats.minutesReadToday)")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    Text("min")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if let target = stats.targetMinutesPerDay {
                        Text("/")
                            .font(.system(.title, design: .rounded))
                        Text("\(target)")
                            .font(.system(.title, design: .rounded))
                            .bold()
                        Text("min")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                if let target = stats.targetMinutesPerDay {
                    ProgressView(value: Double(stats.minutesReadToday), total: Double(target))
                        .tint(stats.isDailyGoalMet ? .green : .orange)
                }
            }
            Spacer()
            
            Image(systemName: stats.isDailyGoalMet ? "checkmark.seal.fill" : "timer")
                .font(.system(size: 40))
                .foregroundStyle(stats.isDailyGoalMet ? .green : .orange)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDay = formatter.string(from: .now)
        return currentDay
    }
}

#Preview {
    TodayProgressCardWidget(stats: ReadingProgressStats(
        targetBooks: 12,
        booksReadThisYear: 5,
        bookCompletionsPercentage: 0.42,
        targetMinutesPerDay: 30,
        minutesReadToday: 18,
        isDailyGoalMet: false
    ))
}
