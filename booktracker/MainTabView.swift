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
    
    @State private var selectedTab: AppTab = .home
    @State private var searchText: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Inicio", systemImage: "house.fill", value: .home) {
                HomeView(viewModel: DIContainer.shared.makeHomeViewModel())
            }
            
            Tab("Libros", systemImage: "books.vertical.fill", value: .books) {
                BookListView(viewModel: DIContainer.shared.makeBookListViewModel())
            }
            
            Tab("Estadísticas", systemImage: "chart.bar.xaxis", value: .statistics) {
                Text("Pantalla de estadísticas en construcción")
            }
            
            Tab("Ajustes", systemImage: "gearshape.fill", value: .settings) {
                Text("Pantalla de ajustes en construcción")
            }
            
            Tab(value: .search, role: .search) {
                NavigationStack {
                    SearchView(viewModel: DIContainer.shared.makeSearchViewModel())
                }
                .searchable(text: $searchText, prompt: "Buscar libros")
            }
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}
