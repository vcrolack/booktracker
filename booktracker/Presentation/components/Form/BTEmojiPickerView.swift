//
//  BTEmojiPickerView.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import SwiftUI

struct BTEmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss
    
    var title: String = "Selector de emojis"

    let emojisAvailables = ["📖", "📕", "🧐", "🧠", "☕️", "✨", "🌟", "🐱", "🦊", "🦉", "🚀", "💡", "🎨", "🎭", "🎧", "🌍", "🌈", "🔥"]
    let columns = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(emojisAvailables, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 45))
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(emoji == selectedEmoji ? Color.accentColor : Color.clear, lineWidth: 2))
                            .onTapGesture {
                                selectedEmoji = emoji
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cerrar") { dismiss() }
            }
        }
        .presentationDetents([.medium])
    }
    

}

#Preview {
    BTEmojiPickerView(selectedEmoji: .constant("📖"))
}
