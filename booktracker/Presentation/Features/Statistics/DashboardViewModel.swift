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
    private let getWeeklyReadingSessions: GetWeeklyReadingSessionsUseCaseProtocol
    
    var todayStats: ReadingProgressStats?
    var monthlyEffort: [MonthlyEffort] = []
    var heatmapContribution: [DailyContribution] = []
    var weeklySessions: [ReadingSession] = []
    
    var isLoading = false
    var errorMessage: String? = nil
    
    init(
        getTodayStats: GetDashboardTodayStatsUseCaseProtocol,
        getMonthlyEffort: GetMonthlyEffortUseCaseProtocol,
        getReadingHeatmap: GetReadingHeatmapUseCaseProtocol,
        getWeeklyReadingSessions: GetWeeklyReadingSessionsUseCaseProtocol
    ) {
        self.getTodayStats = getTodayStats
        self.getMonthlyEffort = getMonthlyEffort
        self.getReadingHeatmap = getReadingHeatmap
        self.getWeeklyReadingSessions = getWeeklyReadingSessions
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        let currentYear = Calendar.current.component(.year, from: .now)
        
        async let statsTask = try? getTodayStats.execute(year: currentYear)
        async let effortTask = try? getMonthlyEffort.execute(year: currentYear)
        async let heatmapTask = try? getReadingHeatmap.execute(year: currentYear)
        async let weeklySessionsTask = try? getWeeklyReadingSessions.execute(for: Date())
        
        let (stats, effort, heatmap, weeklySessions) = await (statsTask, effortTask, heatmapTask, weeklySessionsTask)
        
        self.todayStats = stats
        self.monthlyEffort = effort ?? []
        self.heatmapContribution = heatmap ?? []
        self.weeklySessions = weeklySessions ?? []
        
        if stats == nil {
            self.errorMessage = "Define tu meta de \(currentYear) 📖"
        }
        
        isLoading = false
    }
}
