//
//  CoverPickerView.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import SwiftUI
import PhotosUI

struct CoverPickerView: View {
    @Binding var imageData: Data?
    
    @State private var selection: PhotosPickerItem? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 210)
                        .cornerRadius(12)
                        .clipped()
                        .shadow(radius: 8)
                } else {
                    placeholderView
                }
                
                if isLoading {
                    ProgressView()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                }
            }
            
            PhotosPicker(
                selection: $selection,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(imageData == nil ? "Añadir portada" : "Cambiar portada", systemImage: "photo.badge.plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .onChange(of: selection) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
            }
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.secondarySystemBackground))
            .frame(width: 150, height: 210)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                    Text("Sin portada")
                        .font(.caption)
                }
                    .foregroundStyle(.secondary)
            )
    }
    
    @MainActor
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.imageData = data
            }
        } catch {
            print("[COVER PICKER] Error loading image data: \(error)")
        }
    }
}

#Preview {
    CoverPickerView(imageData: .constant(nil))
}
