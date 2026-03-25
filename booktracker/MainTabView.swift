//
//  MainTabView.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct MainTabView: View {
    enum AppTab: Hashable {
        case home
        case books
        case statistics
        case settings
        case search
    }
    
    @Environment(GlobalSessionManager.self) private var sessionManager
    
    @State private var selectedTab: AppTab = .home
    @State private var searchText: String = ""
    
    private var isSheetPresented: Binding<Bool> {
        Binding(
            get: { sessionManager.isSessionSheetPresented },
            set: { sessionManager.isSessionSheetPresented = $0 }
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Inicio", systemImage: "house.fill", value: .home) {
                HomeView(viewModel: DIContainer.shared.makeHomeViewModel())
            }
            
            Tab("Libros", systemImage: "books.vertical.fill", value: .books) {
                BookListView(
                    viewModel: DIContainer.shared.makeBookListViewModel(),
                    initialFilter: nil
                )
            }
            
            Tab("Estadísticas", systemImage: "chart.bar.xaxis", value: .statistics) {
                DashboardView(viewModel: DIContainer.shared.makeDashboardViewModel())
            }
            
            Tab("Ajustes", systemImage: "gearshape.fill", value: .settings) {
                SettingsView(viewModel: DIContainer.shared.makeSettingsViewModel())
            }
            
            Tab(value: .search, role: .search) {
                NavigationStack {
                    SearchView(viewModel: DIContainer.shared.makeSearchViewModel())
                }
                .searchable(text: $searchText, prompt: "Buscar libros")
            }
        }
        .tint(.blue)
        .tabViewBottomAccessory(isEnabled: sessionManager.isSessionActive) {
            if let session = sessionManager.activeSession, let book = sessionManager.activeBook {
                BTActiveSessionBannerView(book: book, session: session) {
                    sessionManager.isSessionSheetPresented = true
                }
            }
        }
        .task {
            await sessionManager.checkActiveSession()
        }
        .sheet(isPresented: Bindable(sessionManager).isSessionSheetPresented) {
            if let session = sessionManager.activeSession, let book = sessionManager.activeBook {
                StartReadingSessionView(
                    viewModel: DIContainer.shared.makeStartReadingSessionViewModel(
                        book: book,
                        activeSession: session,
                        finishSessionUseCase: DIContainer.shared.makeFinishReadingSessionUseCase(),
                        createSessionUseCase: DIContainer.shared.makeCreateReadingSessionUseCase(),
                        deleteSessionUseCase: DIContainer.shared.makeDeleteReadingSessionUseCase()
                    )
                )
            }
        }
        .onChange(of: sessionManager.isSessionSheetPresented) { oldValue, newValue in
            Task {
                await sessionManager.checkActiveSession()
            }
        }
        .onOpenURL { url in
            if url.absoluteString == "booktracker://activeSession" {
                if sessionManager.activeSession != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        sessionManager.isSessionSheetPresented = true
                    }
                }
            }
        }
    }
}

#Preview {
    let mockSessionManager = GlobalSessionManager(getActiveSessionUseCase: DIContainer.shared.makeGetActiveReadingSessionUseCase(), fetchBookUseCase: DIContainer.shared.makeFetchBookUseCase())
    
    MainTabView()
        .environment(mockSessionManager)
}
