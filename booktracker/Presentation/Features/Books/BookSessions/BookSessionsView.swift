//
//  BooksSessionsView.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import SwiftUI

struct BookSessionsView: View {
    @State var viewModel: BookSessionsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView("Cargando historial...")
                        .padding(.top, 50)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Ups, algo falló",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.sessions.isEmpty {
                    BTEmptyStateView(title: "No tenemos métricas para ti", iconName: "chart.bar.xaxis", description: "Prueba registrando tu primera lectura!")
                } else {
                    if let stats = viewModel.stats {
                        HStack(spacing: 12) {
                            BTStatCardView(title: "Páginas", value: "\(stats.totalPagesRead)", iconName: "book.fill")
                            BTStatCardView(title: "Pág/hora", value: String(format: "%.1f", stats.averagePagesPerHour), iconName: "bolt.fill", iconColor: .yellow)
                            BTStatCardView(title: "Racha", value: "\(stats.currentStreakDays) días", iconName: "flame.fill", iconColor: .orange)
                        }
                        .padding()
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Historial de lectura")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if viewModel.sessions.isEmpty {
                        BTEmptyStateView(title: "No hay sesiones de lectura registradas", iconName: "book.closed.fill", description: "¡Vamos a abrir un libro!")
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sessions) { session in
                                BTSessionRowView(session: session)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSessions()
        }
    }
    
    
}

#Preview {
    BookSessionsView(viewModel: DIContainer.shared.makeBookSessionsViewModel(bookId: UUID()))
}
