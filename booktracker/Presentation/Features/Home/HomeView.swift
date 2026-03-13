//
//  HomeView.swift
//  booktracker
//
//  Created by Victor rolack on 06-03-26.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel
    @State private var showingAddBook: Bool = false
    @State private var selectedBookForSession: Book? = nil
    @State private var showingActiveSessionSheet: Bool = false
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        currentReadingSection
                        
                        if !viewModel.upNextBooks.isEmpty {
                            upNextSection
                        }
                        
                        if !viewModel.recentlyFinishedBooks.isEmpty {
                            recentlyFinishedSection
                        }
                    }
                    .padding(.bottom, 80)
                    .padding(.vertical)
                }
                .background(Color(UIColor.systemBackground))
                .safeAreaInset(edge: .bottom) {
                    if let session = viewModel.activeSession, let book = viewModel.activeBook {
                        BTActiveSessionBannerView(book: book, session: session) {
                            showingActiveSessionSheet = true
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.activeSession != nil)
                    }
                }
                .task {
                    await viewModel.loadDashboard()
                    await viewModel.checkForActiveSession(in: viewModel.currentReadingBooks)
                }
                .onChange(of: selectedBookForSession) { oldValue, newValue in
                    if oldValue != nil && newValue == nil {
                        Task {
                            await viewModel.loadDashboard()
                        }
                    }
                }
                .sheet(isPresented: $showingAddBook) {
                    BookFormView(viewModel: DIContainer.shared.makeBookFormViewModel())
                }
                .sheet(item: $selectedBookForSession) { book in
                    StartReadingSessionView(
                        viewModel: DIContainer.shared.makeStartReadingSessionViewModel(
                            book: book,
                            finishSessionUseCase: DIContainer.shared.makeFinishReadingSessionUseCase(),
                            createSessionUseCase: DIContainer.shared.makeCreateReadingSessionUseCase(),
                            deleteSessionUseCase: DIContainer.shared.makeDeleteReadingSessionUseCase()
                        )
                    )
                }
                .sheet(isPresented: $showingActiveSessionSheet) {
                    if let session = viewModel.activeSession, let book = viewModel.activeBook {
                        StartReadingSessionView(
                            viewModel: DIContainer.shared.makeStartReadingSessionViewModel(
                                book: book,
                                activeSession: session, // ¡Inyectamos la sesión viva!
                                finishSessionUseCase: DIContainer.shared.makeFinishReadingSessionUseCase(),
                                createSessionUseCase: DIContainer.shared.makeCreateReadingSessionUseCase(),
                                deleteSessionUseCase: DIContainer.shared.makeDeleteReadingSessionUseCase()
                            )
                        )
                    }
                }
        }
    }
    
    // MARK: - 🌤️ Componentes Visuales
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, Vitocondrio 👋🏻")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Es un gran día para avanzar en tus lecturas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingAddBook = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var currentReadingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Leyendo ahora")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if viewModel.currentReadingBooks.isEmpty {
                emptyReadingState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.currentReadingBooks) { book in
                            CurrentReadingWidget(book: book) {
                                selectedBookForSession = book
                            }
                                .containerRelativeFrame(.horizontal) { length, _ in
                                    length - 48
                                }
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private var upNextSection: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text("Próximas lecturas")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(viewModel.upNextBooks) { book in
                        NavigationLink(destination: BookDetailView(viewModel: DIContainer.shared.makeBookDetailViewModel(book: book))) {
                            UpNextBookCell(book: book)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var recentlyFinishedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Últimos terminados")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentlyFinishedBooks) { book in
                    NavigationLink(destination: BookDetailView(viewModel: DIContainer.shared.makeBookDetailViewModel(book: book))) {
                        FinishedBookCell(book: book)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var emptyReadingState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundStyle(.gray.opacity(0.5))
            Text("No estás leyendo nada actualmente.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}



// MARK: - 🧪 Mocks para el Preview

// 1. Declaramos el struct AFUERA del #Preview
struct MockGetAllBooksUseCase: FetchBooksUseCaseProtocol {
    func execute(filter: BookFilter? = nil) async throws -> [Book] {
        return [
            try! Book(
                id: UUID(),
                title: "Neuromante",
                author: "William Gibson",
                pages: 350,
                currentPage: 120,
                ownership: .owner,
                status: .finalized,
                coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg"
            ),
            try! Book(
                id: UUID(),
                title: "Conde Cero",
                author: "William Gibson",
                pages: 350,
                currentPage: 120,
                ownership: .owner,
                status: .reading,
                coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg"
            ),
            try! Book(
                id: UUID(),
                title: "Snow Crash",
                author: "Neal Stephenson",
                pages: 480,
                currentPage: 50,
                ownership: .owner,
                status: .toRead,
                coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/22/e1/22e118991cc31e84dfa1d821361c4710.jpg"
            ),
            try! Book(
                id: UUID(),
                title: "Clean Architecture",
                author: "Robert C. Martin",
                pages: 432,
                currentPage: 300,
                ownership: .owner,
                status: .reading,
                coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/57/03/5703f56e9c9f28d7d4f9f7833a6bce4f.jpg"
            )
        ]
    }
}

#Preview {
    // 2. Instanciamos el ViewModel (las variables sí están permitidas)
    let mockViewModel = HomeViewModel(fetchBooksUseCase: MockGetAllBooksUseCase(), getActiveSessionUseCase: DIContainer.shared.makeGetActiveReadingSessionUseCase())
    
    // 3. Simplemente llamamos a la vista, sin la palabra "return"
    HomeView(viewModel: mockViewModel)
}
