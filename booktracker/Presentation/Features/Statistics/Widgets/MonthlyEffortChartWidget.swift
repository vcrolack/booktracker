//
//  MonthlyEffortChartWidget.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI
import Charts

struct MonthlyEffortChartWidget: View {
    let efforts: [MonthlyEffort]
    
    var body: some View {
        Chart(efforts) { effort in
            BarMark(
                x: .value("Mes", effort.monthName),
                y: .value("Minutos", effort.totalMinutes)
            )
            .foregroundStyle(.blue.gradient)
            .cornerRadius(4)
        }
        .frame(height: 100)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    MonthlyEffortChartWidget(efforts: [
        MonthlyEffort(month: 1, totalMinutes: 120),
        MonthlyEffort(month: 2, totalMinutes: 90),
        MonthlyEffort(month: 3, totalMinutes: 200),
        MonthlyEffort(month: 4, totalMinutes: 60),
        MonthlyEffort(month: 5, totalMinutes: 150),
    ])
}
