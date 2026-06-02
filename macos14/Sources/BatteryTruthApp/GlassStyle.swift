import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.012, green: 0.020, blue: 0.026),
                    Color(red: 0.05, green: 0.10, blue: 0.14),
                    Color(red: 0.02, green: 0.17, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.green.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 44)
                .offset(x: -190, y: -260)

            Circle()
                .fill(Color.cyan.opacity(0.17))
                .frame(width: 300, height: 300)
                .blur(radius: 54)
                .offset(x: 170, y: 210)
        }
        .ignoresSafeArea()
    }
}

struct GlassPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.070))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.black.opacity(0.10))
                    )
            )
            .shadow(color: .black.opacity(0.16), radius: 12, y: 8)
    }
}

struct GlassCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white.opacity(0.10), in: Capsule())
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }

    func glassCapsule() -> some View {
        modifier(GlassCapsuleModifier())
    }
}
