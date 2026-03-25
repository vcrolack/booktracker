//
//  ReadingGoalFormViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class ReadingGoalFormViewModel {
    var targetBooks: Int = 1
    var targetMinutes: Int = 10
    var isMinutesGoalEnabled: Bool = false
    
    var isLoading = false
    var errorMessage: String? = nil
    
    private let createGoalUseCase: CreateReadingGoalUseCaseProtocol
    
    init(createGoalUseCase: CreateReadingGoalUseCaseProtocol) {
        self.createGoalUseCase = createGoalUseCase
    }
    
    func createGoal(for year: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let command = CreateReadingGoalCommand(year: year, targetBooks: targetBooks, targetMinutesPerDay: isMinutesGoalEnabled ? targetMinutes : nil)
        
        do {
            _ = try await createGoalUseCase.execute(command: command)
            isLoading = false
            return true
        } catch CreateReadingGoalError.goalAlreadyExistsForYear {
            self.errorMessage = "Ya tienes una meta para el \(year). Intenta editarla mejor."
        } catch let error as ReadingGoalDomainError {
            self.errorMessage = error == .invalidTargetBooks ? "Mínimo 1 libro" : "Minutos inválidos"
        } catch {
            self.errorMessage = "Error inesperado"
        }
        
        isLoading = false
        return false
    }
}
