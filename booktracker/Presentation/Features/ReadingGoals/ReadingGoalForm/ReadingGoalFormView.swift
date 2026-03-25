//
//  ReadingGoalFormView.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI

struct ReadingGoalFormView: View {
    @State var viewModel: ReadingGoalFormViewModel
    @Environment(\.dismiss) var dismiss
    let year: Int
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Objetivo: \(viewModel.targetBooks) libros", value: $viewModel.targetBooks, in: 1...365)
                    Text("¿Cuántos libros te gustaría terminar este año?")
                        .font(.caption).foregroundStyle(.secondary)
                } header: {
                    Text("Meta Anual")
                }
                
                Section {
                    Toggle("Meta de tiempo diario", isOn: $viewModel.isMinutesGoalEnabled)
                    
                    if viewModel.isMinutesGoalEnabled {
                        Stepper("\(viewModel.targetMinutes) min / día", value: $viewModel.targetMinutes, in: 1...1440, step: 5)
                    }
                } header: {
                    Text("Hábito Diario")
                }
                
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption).bold()
                }
            }
            .navigationTitle("Meta \(String(year))")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        Task {
                            if await viewModel.createGoal(for: year) { dismiss() }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

private struct PreviewCreateGoalUseCase: CreateReadingGoalUseCaseProtocol {
    func execute(command: CreateReadingGoalCommand) async throws -> UUID { UUID() }
}

#Preview {
    ReadingGoalFormView(
        viewModel: ReadingGoalFormViewModel(createGoalUseCase: PreviewCreateGoalUseCase()),
        year: 2025
    )
}
