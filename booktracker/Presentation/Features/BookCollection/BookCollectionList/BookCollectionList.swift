//
//  BookCollectionList.swift
//  booktracker
//
//  Created by Victor rolack on 19-03-26.
//

import SwiftUI

struct BookCollectionList: View {
    @State var viewModel: BookCollectionListViewModel
    @State private var showingCreateSheet = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.bookCollections.isEmpty && !viewModel.isLoading {
                    BTEmptyStateView(title: "No hay colecciones", iconName: "list.bullet.rectangle.portrait.fill", description: "¡Crea una nueva lista!")
                } else {
                    collectionView
                }
            }
            .navigationTitle("Colecciones")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Buscar colección...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label : {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .task {
                await viewModel.fetchCollections()
            }
            .sheet(isPresented: $showingCreateSheet) {
                Task { await viewModel.fetchCollections() }
            } content: {
                BookCollectionFormView(viewModel: DIContainer.shared.makeBookCollectionFormViewModel())
            }
        }
    }
    
    private var collectionView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(viewModel.filteredCollections) { bookCollection in
                    NavigationLink {
                        // TODO: Implements Book Collection Detail View
                        Text("Detalle de \(bookCollection.name)")
                    } label: {
                        BookCollectionCellView(bookCollection: bookCollection)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.fetchCollections()
        }
    }
}

#Preview {
    let bookCollectionsMock: [BookCollection?] = [
        try? BookCollection(name: "Coleccion 1"),
        try? BookCollection(name: "Coleccion 2"),
        try? BookCollection(name: "Coleccion 3"),
        try? BookCollection(name: "Coleccion 4"),
        try? BookCollection(name: "Coleccion 5"),
        try? BookCollection(name: "Coleccion 6"),
        try? BookCollection(name: "Coleccion 7"),
        try? BookCollection(name: "Coleccion 8"),
    ]
    
    let vm = DIContainer.shared.makeBookCollectionListViewModel()
    vm.bookCollections = bookCollectionsMock.compactMap { $0 }
    
    return BookCollectionList(viewModel: vm)
}
