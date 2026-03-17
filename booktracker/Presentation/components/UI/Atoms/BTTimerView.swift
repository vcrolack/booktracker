import SwiftUI

struct BTTimerView: View {
    let elapsedSeconds: TimeInterval
    
    var body: some View {
        // 1. Calculamos los componentes del tiempo
        let totalSeconds = Int(elapsedSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        // 2. Construimos la píldora de cristal
        HStack(spacing: 8) {
            timeComponent(value: hours, unit: "h")
            colonSpacer
            timeComponent(value: minutes, unit: "m")
            colonSpacer
            timeComponent(value: seconds, unit: "s")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background {
            // Contenedor Glassmorphic (Cristal esmerilado)
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                // Borde brillante superior para dar efecto 3D
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
    
    // MARK: - Subcomponentes Visuales
    
    private func timeComponent(value: Int, unit: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            // El número gigante y elegante
            Text(String(format: "%02d", value))
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(
                    // Un gradiente metálico sutil en el texto
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // La letra pequeñita de la unidad
            Text(unit)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
    
    private var colonSpacer: some View {
        Text(":")
            .font(.system(size: 40, weight: .ultraLight, design: .rounded))
            .foregroundColor(.secondary.opacity(0.3))
            .offset(y: -4) // Pequeño ajuste visual para que quede centrado con los números
    }
}
