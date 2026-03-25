//
//  DashboardViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class DashboardViewModel {
    private let getTodayStats: GetDashboardTodayStatsUseCaseProtocol
    private let getMonthlyEffort: GetMonthlyEffortUseCaseProtocol
    private let getReadingHeatmap: GetReadingHeatmapUseCaseProtocol
    
    var todayStats: ReadingProgressStats?
    var monthlyEffort: [MonthlyEffort] = []
    var heatmapContribution: [DailyContribution] = []
    
    var isLoading = false
    var errorMessage: String? = nil
    
    init(
        getTodayStats: GetDashboardTodayStatsUseCaseProtocol,
        getMonthlyEffort: GetMonthlyEffortUseCaseProtocol,
        getReadingHeatmap: GetReadingHeatmapUseCaseProtocol
    ) {
        self.getTodayStats = getTodayStats
        self.getMonthlyEffort = getMonthlyEffort
        self.getReadingHeatmap = getReadingHeatmap
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        let currentYear = Calendar.current.component(.year, from: .now)
        
        async let statsTask = try? getTodayStats.execute(year: currentYear)
        async let effortTask = try? getMonthlyEffort.execute(year: currentYear)
        async let heatmapTask = try? getReadingHeatmap.execute(year: currentYear)
        
        let (stats, effort, heatmap) = await (statsTask, effortTask, heatmapTask)
        
        self.todayStats = stats
        self.monthlyEffort = effort ?? []
        self.heatmapContribution = heatmap ?? []
        
        if stats == nil {
            self.errorMessage = "Define tu meta de \(currentYear) 📖"
        }
        
        isLoading = false
    }
}
