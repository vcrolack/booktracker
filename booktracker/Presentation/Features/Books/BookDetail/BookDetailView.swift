//
//  BookDetailView.swift
//  booktracker
//
//  Created by Victor rolack on 25-02-26.
//

import SwiftUI

struct BookDetailView: View {
    @State var viewModel: BookDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                progressSection
                actionsSection
                milestonesSection
                metadataSection
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    viewModel.showingEditSheet = true
                }
            }
        }
        .alert("Abandonar libro", isPresented: $viewModel.showingAbandonAlert) {
            bookAbandonedAlert
        } message: {
            Text("¿Por qué dejas de leer este libro? Puedes dejar una nota para tu yo del futuro.")
        }
        .sheet(isPresented: $viewModel.showingFinishSheet) {
            bookFinishedSheet
        }
        .sheet(isPresented: $viewModel.showingEditSheet, onDismiss: {
            Task {
                await viewModel.refreshBook()
            }
        }) {
            BookFormView(viewModel: DIContainer.shared.makeBookFormViewModel(book: viewModel.book))
        }
        .presentationDetents([.medium, .large])
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            BTCoverView(urlString: viewModel.book.coverUrl, width: 160, height: 240)
                .frame(width: 160, height: 240)
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text(viewModel.book.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(viewModel.book.author)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                BTBadgeView(
                    text: viewModel.book.status.uiLabel,
                    color: viewModel.book.status.uiColor,
                    iconName: viewModel.book.status.uiIcon
                )
            }
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        switch viewModel.book.status {
        case .wishlist, .toRead:
            EmptyView()
        case .reading, .finalized, .abandoned:
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(viewModel.book.currentPage) / \(viewModel.book.pages) páginas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(
                    value: Double(viewModel.book.currentPage),
                    total: Double(viewModel.book.pages)
                )
                .tint(viewModel.book.status.uiColor)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        VStack(spacing: 12) {
            switch viewModel.book.status {
            case .wishlist:
                Button(action: {
                    Task {
                        await viewModel.acquireBookForReading()
                    }
                }) {
                    actionButtonLabel(title: "Para leer", icon: "book.fill", color: .gray)
                }
            case .toRead:
                Button(action: {
                    Task {
                        await viewModel.startReading()
                    }
                }) {
                    actionButtonLabel(title: "Empezar a leer", icon: "book.fill", color: .blue)
                }
            case .reading:
                Button(action: {
                    viewModel.showingFinishSheet = true
                }) {
                    actionButtonLabel(title: "Terminar lectura", icon: "checkmark.circle.fill", color: .green)
                }
                
                Button(action: {
                    viewModel.showingAbandonAlert = true
                }) {
                    actionButtonLabel(title: "Abandonar", icon: "xmark.octagon.fill", color: .red, isSecondary: true)
                }
                
            case .finalized, .abandoned:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detalles")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                metadataRow(title: "Propiedad", value: viewModel.book.ownership.rawValue.capitalized)
                Divider().padding(.leading)
                
                if let isbn = viewModel.book.isbn {
                    metadataRow(title: "ISBN", value: isbn)
                }
                
                if let editorial = viewModel.book.editorial {
                    metadataRow(title: "Editorial", value: editorial)
                }
                
                if let genre = viewModel.book.genre {
                    metadataRow(title: "Género", value: genre)
                }
                
                
            }
        }
    }
    
    @ViewBuilder
    private var milestonesSection: some View {
        //viewModel.book.startDate != nil || viewModel.book.userRating != nil || viewModel.book.abandonReason != nil
        if true {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mi lectura")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    if let startDate = viewModel.book.startDate {
                        metadataRow(title: "Iniciado el", value: startDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                    if let endDate = viewModel.book.endDate {
                        if viewModel.book.startDate != nil { Divider().padding(.leading) }
                        let title = viewModel.book.status == .abandoned ? "Abandonado el" : "Finalizado el"
                        metadataRow(title: title, value: endDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                    if let userRating = viewModel.book.userRating {
                        if viewModel.book.startDate != nil || viewModel.book.endDate != nil { Divider().padding(.leading) }
                        metadataRow(title: "Calificación", value: String(repeating: "⭐️", count: Int(userRating)))
                    }
                    
                    if let abandonReason = viewModel.book.abandonReason, !abandonReason.isEmpty {
                        Divider().padding(.leading)
                        metadataTextRow(title: "Razón de abandono", text: abandonReason)
                    }
                    
                    if let review = viewModel.book.userReview, !review.isEmpty {
                        Divider().padding(.leading)
                        metadataTextRow(title: "Reseña", text: review)
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var bookFinishedSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Calificación")) {
                    Picker("Estrellas", selection: $viewModel.tempRating) {
                        ForEach(1...5, id: \.self) { rating in
                            Text(String(repeating: "⭐️", count: rating)).tag(rating)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(
                    header: Text("Reseña"),
                    footer: Text("Opcional: ¿Qué te pareció el libro?")
                ) {
                    TextEditor(text: $viewModel.tempReview)
                        .frame(minWidth: 100)
                }
            }
            .navigationTitle("¡Felicidades!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        viewModel.showingFinishSheet = false
                        viewModel.tempReview = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            await viewModel.confirmFinishReading()
                            viewModel.showingFinishSheet = false
                        }
                    }
                    .bold()
                }
            }
        }
    }
    
    @ViewBuilder
    private var bookAbandonedAlert: some View {
        TextField("Razón (Opcional)", text: $viewModel.tempAbandonReason)
        
        Button("Cancelar", role: .cancel) {
            viewModel.tempAbandonReason = ""
        }
        
        Button("Confirmar", role: .destructive) {
            Task {
                await viewModel.confirmAbandone()
            }
        }
    }
    
    private func actionButtonLabel(title: String, icon: String, color: Color, isSecondary: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title).fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSecondary ? color.opacity(0.1) : color)
        .foregroundColor(isSecondary ? color : .white)
        .cornerRadius(12)
    }
    
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .padding()
    }
    
    private func metadataTextRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).foregroundColor(.secondary)
            Text(text)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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

        return NavigationStack {
            BookDetailView(viewModel: DIContainer.shared.makeBookDetailViewModel(book: mockBook))
        }
}
