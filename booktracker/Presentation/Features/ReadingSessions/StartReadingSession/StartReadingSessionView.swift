//
//  StartReadingSessionView.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

import SwiftUI

enum ReadingSessionStep {
    case tracking
    case finishing
}

struct StartReadingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: StartReadingSessionViewModel
    @State private var currentStep: ReadingSessionStep = .tracking
    
    init(viewModel: StartReadingSessionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            NavigationStack {
                VStack {
                    if currentStep == .tracking {
                        trackingView
                    } else {
                        finishingView
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Botón Izquierdo: Terminar (solo visible si estamos trackeando y el timer está pausado o corriendo)
                    ToolbarItem(placement: .topBarTrailing) {
                        if currentStep == .tracking {
                            Button("Terminar") {
                                // Pausamos el timer de fondo antes de pasar a la pantalla final
                                if viewModel.isReading {
                                    viewModel.toggleSession()
                                }
                                withAnimation {
                                    currentStep = .finishing
                                }
                            }
                            // Opcional: Deshabilitar si no ha pasado ni 1 segundo
                            .disabled(viewModel.elapsedSeconds == 0)
                        }
                    }
                    
                    // Botón Derecho: Cerrar
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            // Si está corriendo, podrías mostrar un Alert de confirmación antes de cerrar
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .interactiveDismissDisabled(viewModel.isReading || currentStep == .finishing)
                .alert("Error", isPresented: showingError) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
            }
        }

    private var showingError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
    
    private var trackingView: some View {
        VStack(spacing: 40) {
            BTCoverView(urlString: viewModel.book.coverUrl, width: 150, height: 220)
                .shadow(radius: 5)
            
            BTTimerView(elapsedSeconds: viewModel.elapsedSeconds)
            
            BTLiquidButton(
                systemName: viewModel.isReading ? "pause.fill" : "play.fill",
                color: viewModel.isReading ? .orange : .green
            ) {
                viewModel.toggleSession()
            }
            // Pequeño ajuste para centrarlo visualmente
            .padding(.bottom, 60)
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private var finishingView: some View {
        VStack(spacing: 30) {
            Text("¡Sesión Terminada!")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 40) {
                VStack {
                    Text("Tiempo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeString(from: viewModel.elapsedSeconds))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text("¿En qué página quedaste?")
                    .font(.headline)
                
                TextField("Página final", value: $viewModel.endPage, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
            }
            .padding(.horizontal, 40)
            
            let percentage = (Double(viewModel.endPage) / Double(viewModel.book.pages)) * 100
            VStack {
                Text("\(percentage, specifier: "%.1f")%")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                Text("Completado")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                Task {
                    do {
                        try await viewModel.finishSession()
                        dismiss()
                    } catch {
                        // El error ya se guarda en viewModel.errorMessage
                    }
                }
            } label: {
                Text(viewModel.isLoading ? "Guardando..." : "Guardar progreso")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    let mockBook = try! Book(
        id: UUID(),
        title: "Percy Jackson",
        author: "Rick Riordan",
        pages: 321,
        currentPage: 0,
        ownership: .owner,
        status: .reading,
        coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg",
        isbn: "123123123123123"
    )
    StartReadingSessionView(
        viewModel: DIContainer.shared.makeStartReadingSessionViewModel(
            book: mockBook,
            finishSessionUseCase: DIContainer.shared.makeFinishReadingSessionUseCase(),
            createSessionUseCase: DIContainer.shared.makeCreateReadingSessionUseCase()
        )
    )
}
