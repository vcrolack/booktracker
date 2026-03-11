import SwiftUI

struct BTLiquidButton: View {
    let systemName: String
    let color: Color
    let action: () -> Void
    
    // Un estado local para animar el toque (el efecto "líquido")
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 1. Capa Base: Círculo con Material de Vidrio (Blur de fondo)
                Circle()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 10)
                
                // 2. Capa de Gradiente Especular (Luz desde arriba a la izquierda)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white.opacity(0.6), .white.opacity(0.05)]),
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 70
                        )
                    )
                    .blur(radius: 1)
                    // Recortamos para que no se salga del círculo
                    .clipShape(Circle())
                
                // 3. Sombra Interna (Profundidad en la parte inferior derecha)
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 2)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 3, y: 3)
                    .clipShape(Circle())
                    // Una segunda sombra interna inversa para suavizar
                    .shadow(color: .white.opacity(0.1), radius: 3, x: -3, y: -3)
                    .clipShape(Circle())
                
                // 4. El Icono con su propio gradiente
                Image(systemName: systemName)
                    .resizable()
//                    .aspectRatio(contentContentMode: .fit)
                    .frame(width: 35, height: 35)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.7), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    // Pequeña sombra al icono para separarlo del vidrio
                    .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 2)
            }
            .frame(width: 90, height: 90)
            // 💧 Efecto Líquido al presionar: Escala y opacidad
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
        }
        // Usamos unButtonStyle personalizado para detectar el toque sin retrasos
        .buttonStyle(PressedButtonStyle(isPressed: $isPressed))
    }
}

// Helper para detectar cuando el botón está siendo presionado
struct PressedButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = newValue
                }
            }
    }
}
