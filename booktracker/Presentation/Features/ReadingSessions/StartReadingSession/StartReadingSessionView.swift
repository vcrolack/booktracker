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
    @Environment(\.scenePhase) private var scenePhase
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
                    ToolbarItem(placement: .topBarTrailing) {
                        if currentStep == .tracking {
                            Button("Terminar") {
                                if viewModel.isReading {
                                    viewModel.toggleSession()
                                }
                                withAnimation {
                                    currentStep = .finishing
                                }
                            }
                            .disabled(viewModel.elapsedSeconds == 0)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if viewModel.elapsedSeconds > 0 {
                                if viewModel.isReading {
                                    viewModel.toggleSession()
                                }
                                viewModel.cancelSaveSession = true
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .background, .inactive:
                        viewModel.appDidEnterBackground()
                    case .active:
                        viewModel.appWillEnterForeground()
                    @unknown default:
                        break
                    }
                }
                .alert("¿Seguro que quieres cancelar?", isPresented: $viewModel.cancelSaveSession) {
                    Button("Confirmar", role: .destructive) {
                        Task {
                            await viewModel.cancelSession()
                            dismiss()
                        }
                    }
                    Button("Volver", role: .cancel) { }
                } message: {
                    Text("Si cierras, esta sesión no será guardada.")
                }
                .alert("Error", isPresented: showingError) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
        }

    private var showingError: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
    
    private var trackingView: some View {
            ZStack {
                BTAmbientBackgroundView(urlString: viewModel.book.coverUrl)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    BTCoverView(urlString: viewModel.book.coverUrl ?? "", width: 150, height: 220)
                        .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
                    
                    BTTimerView(elapsedSeconds: viewModel.elapsedSeconds)
                    
                    BTLiquidButton(
                        systemName: viewModel.isReading ? "pause.fill" : "play.fill",
                        color: viewModel.isReading ? .orange : .green
                    ) {
                        viewModel.toggleSession()
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
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
                BTInputView(endPage: $viewModel.endPage, lastSavedPage: viewModel.book.currentPage, label: "¿En qué página quedaste?")
                
                if let endPage = viewModel.endPage, endPage - viewModel.book.currentPage > 0 {
                    let pagesRead = endPage - viewModel.book.currentPage
                    
                    HStack {
                        Spacer(minLength: 0)
                        Text("Has leído \(pagesRead) \(pagesRead == 1 ? "página" : "páginas")")
                            .bold()
                        Spacer(minLength: 0)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .padding(.horizontal, 40)
            
                VStack {
                    HStack {
                        Spacer(minLength: 0)
                        Text("\(currentPercentage, specifier: "%.1f")%")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Spacer(minLength: 0)
                    }

                    Text("Completado")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            
            
            
            Spacer()
            
            Button {
                Task {
                    do {
                        try await viewModel.finishSession()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    } catch {
                        // El error ya se guarda en viewModel.errorMessage
                    }
                }
            } label: {
                Text(viewModel.isLoading ? "Guardando..." : "Guardar progreso")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cornerRadius(16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(viewModel.isSaveButtonDisabled)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.endPage)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var currentPercentage: Double {
        let targetPage = viewModel.endPage ?? viewModel.book.currentPage
        guard viewModel.book.pages > 0 else { return 0.0 }
        let calculatedPercentage = (Double(targetPage) / Double(viewModel.book.pages)) * 100
        return max(0.0, calculatedPercentage)
    }
}

#Preview {
    let mockBook = try! Book(
        id: UUID(),
        title: "Percy Jackson",
        author: "Rick Riordan",
        pages: 321,
        currentPage: 12,
        ownership: .owner,
        status: .reading,
        coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg",
        isbn: "123123123123123"
    )
    StartReadingSessionView(
        viewModel: DIContainer.shared.makeStartReadingSessionViewModel(
            book: mockBook,
            finishSessionUseCase: DIContainer.shared.makeFinishReadingSessionUseCase(),
            createSessionUseCase: DIContainer.shared.makeCreateReadingSessionUseCase(),
            deleteSessionUseCase: DIContainer.shared.makeDeleteReadingSessionUseCase()
        )
    )
}
