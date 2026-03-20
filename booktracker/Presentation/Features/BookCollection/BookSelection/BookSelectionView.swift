//
//  BookSelectionView.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import SwiftUI

struct BookSelectionView: View {
    @State var viewModel: BookSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (Set<UUID>) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.filteredBooks.isEmpty {
                    BTEmptyStateView(title: "No hay libros para añadir", iconName: "book.fill", description: "Prueba agregando libros en tu biblioteca antes")
                } else {
                    ForEach(viewModel.filteredBooks) { book in
                        Button {
                            viewModel.toggleSelection(for: book.id)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: viewModel.selectedIds.contains(book.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(viewModel.selectedIds.contains(book.id) ? .blue : .secondary)
                                
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Añadir libros")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Buscar por título o autor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") {
                        onSave(viewModel.selectedIds)
                        dismiss()
                    }
                    .bold()
                }
            }
            .task { await viewModel.loadBooks() }
        }
    }
}

#Preview {
    BookSelectionView(
        viewModel: BookSelectionViewModel(
            initialSelectedIds: [],
            fetchBooksUseCase: DIContainer.shared.makeFetchBooksUseCase(),
        ),
        onSave: {_ in }
    )
}
