//
//  BTInputView.swift
//  booktracker
//
//  Created by Victor rolack on 18-05-26.
//

import SwiftUI

struct BTInputView: View {
    @Binding var endPage: Int?
    let lastSavedPage: Int
    let label: String?
    
    @FocusState private var isFieldFocused: Bool
    
    private var isValidationError: Bool {
            guard let currentPage = endPage else { return false }
            return currentPage < lastSavedPage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(label ?? "")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isFieldFocused ? .accentColor : .secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .animation(.easeInOut(duration: 0.2), value: isFieldFocused)
            
            HStack(spacing: 15) {
                Image(systemName: "book.pages")
                    .font(.title2)
                    .foregroundColor(isFieldFocused ? .accentColor : .gray)
                    .scaleEffect(isFieldFocused ? 1.1 : 1.0)
                
                TextField("000", value: $endPage, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .focused($isFieldFocused)
                    .contentTransition(.numericText())
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer(minLength: 0)
                            Button("Listo") {
                                isFieldFocused = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                
                Spacer()
                
                if endPage != nil && isFieldFocused {
                    Button(action: {
                        withAnimation(.spring()) {
                            endPage = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.title3)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.all, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFieldFocused ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: isFieldFocused ? Color.accentColor.opacity(0.15) : Color.clear, radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.25), value: isFieldFocused)
            
            if let currentPage = endPage, currentPage < lastSavedPage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("La página no puede ser menor a la anterior (\(lastSavedPage))")
                }
                .font(.caption)
                .foregroundColor(.red)
                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity
                                ))
                
            }
        }
        .padding()
        .animation(.snappy(duration: 0.35, extraBounce: 0.1), value: isValidationError)
    }
}

struct TestInputContainer: View {
    @State var endPage: Int? = 150
    let lastSavedPage = 120
    
    var body: some View {
        VStack(spacing: 20) {
            BTInputView(endPage: $endPage, lastSavedPage: lastSavedPage, label: "¿En qué página quedaste?")
            
            Button(action: {
                guard let finalPage = endPage, isValid(finalPage) else {
                    print("❌ Error: Datos inválidos. No se guarda.")
                    return
                }
                print("✅ Guardando progreso exitosamente en la página: \(finalPage)")
            }) {
                Text("Confirmar lectura")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundColor(isFormValid ? .white : .secondary)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.horizontal)
        }
    }
    
    private var isFormValid: Bool {
        guard let page = endPage else { return false }
        return isValid(page)
    }
    
    private func isValid(_ page: Int) -> Bool {
        return page >= lastSavedPage
    }
}

#Preview {
    TestInputContainer()
}
