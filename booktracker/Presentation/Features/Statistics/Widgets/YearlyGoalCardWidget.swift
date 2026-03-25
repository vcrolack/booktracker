//
//  YearlyGoalCardWidget.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI

struct YearlyGoalCardWidget: View {
    let stats: ReadingProgressStats
    let year: Int = Calendar.current.component(.year, from: .now)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reto anual \(String(year))")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
            
            HStack(spacing: 20) {
                Gauge(value: stats.bookCompletionsPercentage, in: 0...100) {
                    
                } currentValueLabel: {
                    Text("\(Int(stats.bookCompletionsPercentage))%")
                        .font(.caption)
                        .bold()
                }
                .gaugeStyle(.accessoryCircular)
                .scaleEffect(1.8)
                .tint(Gradient(colors: [.blue, .purple]))
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(stats.booksReadThisYear) libros")
                        .font(.title2)
                        .bold()
                    
                    Text("de un objetivo de \(stats.targetBooks)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if stats.bookCompletionsPercentage >= 100 {
                        Text("¡Meta cumplida!")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progreso del reto anual \(year): \(Int(stats.bookCompletionsPercentage)) por ciento completado")
    }
}

#Preview {
    YearlyGoalCardWidget(stats: ReadingProgressStats(
        targetBooks: 24,
        booksReadThisYear: 10,
        bookCompletionsPercentage: 20.2,
        targetMinutesPerDay: 30,
        minutesReadToday: 15,
        isDailyGoalMet: false
    ))
}
