//
//  DashboardView.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import SwiftUI

struct DashboardView: View {
    @State var viewModel: DashboardViewModel
    @State var showSetGoalSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let stats = viewModel.todayStats {
                        TodayProgressCardWidget(stats: stats)
                    } else {
                        ContentUnavailableView {
                            Label("Sin meta para \(String(Calendar.current.component(.year, from: .now)))", systemImage: "target")
                        } description: {
                            Text("Establece un objetivo para empezar a trackear tu mayordomía de lectura.")
                        } actions: {
                            Button("Configurar meta") {
                                showSetGoalSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        BTHeaderView(title: "Consistencia", icon: "calendar.day.timeline.left")
                        ReadingHeatmapWidget(contributions: viewModel.heatmapContribution)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        BTHeaderView(title: "Esfuerzo mensual", icon: "chart.bar.fill")
                        MonthlyEffortChartWidget(efforts: viewModel.monthlyEffort)
                    }
                    
                    if let stats = viewModel.todayStats {
                        YearlyGoalCardWidget(stats: stats)
                    }
                }
                .padding()
            }
            .navigationTitle("Mi Lectura")
            .background(Color(.systemGroupedBackground))
            .refreshable { await viewModel.loadData() }
            .task { await viewModel.loadData() }
            .sheet(isPresented: $showSetGoalSheet) {
                ReadingGoalFormView(viewModel: DIContainer.shared.makeReadingGoalFormViewModel(), year: Int(Calendar.current.component(.year, from: .now)))
            }
            .overlay {
                if viewModel.isLoading && viewModel.todayStats == nil {
                    ProgressView("Sincronizando mayordomía...")
                }
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: DIContainer.shared.makeDashboardViewModel())
}
