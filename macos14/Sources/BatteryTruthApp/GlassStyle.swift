import SwiftUI

enum BatteryTruthTheme {
    enum ColorToken {
        static let windowTop = Color(red: 0.055, green: 0.058, blue: 0.064)
        static let windowBottom = Color(red: 0.025, green: 0.027, blue: 0.031)
        static let panel = Color(red: 0.092, green: 0.096, blue: 0.106)
        static let panelElevated = Color(red: 0.112, green: 0.118, blue: 0.130)
        static let card = Color(red: 0.078, green: 0.082, blue: 0.092)
        static let border = Color.white.opacity(0.115)
        static let hairline = Color.white.opacity(0.070)
        static let highlight = Color.white.opacity(0.145)
        static let textSecondary = Color.white.opacity(0.62)
        static let textTertiary = Color.white.opacity(0.42)
        static let normal = Color(red: 0.36, green: 0.86, blue: 0.55)
        static let warning = Color(red: 1.00, green: 0.67, blue: 0.30)
        static let critical = Color(red: 1.00, green: 0.34, blue: 0.30)
        static let accent = Color(red: 0.50, green: 0.78, blue: 1.00)
        static let unavailable = Color.white.opacity(0.44)
    }

    enum Radius {
        static let panel: CGFloat = 10
        static let card: CGFloat = 8
        static let control: CGFloat = 7
    }

    enum Spacing {
        static let page: CGFloat = 18
        static let section: CGFloat = 12
        static let item: CGFloat = 10
        static let dense: CGFloat = 6
    }

    enum Font {
        static let title = SwiftUI.Font.system(.title3, design: .default, weight: .semibold)
        static let section = SwiftUI.Font.system(.callout, design: .default, weight: .semibold)
        static let label = SwiftUI.Font.system(.caption, design: .default, weight: .medium)
        static let value = SwiftUI.Font.system(.title3, design: .default, weight: .semibold)
        static let body = SwiftUI.Font.system(.callout, design: .default)
        static let footnote = SwiftUI.Font.system(.footnote, design: .default)
        static let mono = SwiftUI.Font.system(.callout, design: .monospaced, weight: .medium)
    }
}

enum DashboardStatusStyle: Equatable {
    case normal
    case warning
    case critical
    case unavailable
    case neutral

    var color: Color {
        switch self {
        case .normal:
            return BatteryTruthTheme.ColorToken.normal
        case .warning:
            return BatteryTruthTheme.ColorToken.warning
        case .critical:
            return BatteryTruthTheme.ColorToken.critical
        case .unavailable:
            return BatteryTruthTheme.ColorToken.unavailable
        case .neutral:
            return BatteryTruthTheme.ColorToken.accent
        }
    }

    var symbolName: String {
        switch self {
        case .normal:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "xmark.octagon.fill"
        case .unavailable:
            return "minus.circle.fill"
        case .neutral:
            return "info.circle.fill"
        }
    }
}

struct DashboardMetric: Identifiable {
    let id: String
    let title: String
    let value: String
    let subtitle: String?
    let systemImage: String?
    let status: DashboardStatusStyle

    init(
        id: String? = nil,
        title: String,
        value: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        status: DashboardStatusStyle = .neutral
    ) {
        self.id = id ?? title
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.status = status
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                BatteryTruthTheme.ColorToken.windowTop,
                Color(red: 0.038, green: 0.041, blue: 0.048),
                BatteryTruthTheme.ColorToken.windowBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(BatteryTruthTheme.ColorToken.highlight)
                .frame(height: 1)
                .opacity(0.45)
        }
        .ignoresSafeArea()
    }
}

struct PanelSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let elevated: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated ? BatteryTruthTheme.ColorToken.panelElevated : BatteryTruthTheme.ColorToken.panel)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(BatteryTruthTheme.ColorToken.highlight)
                            .frame(height: 1)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(BatteryTruthTheme.ColorToken.border, lineWidth: 0.8)
                    }
            }
            .shadow(color: .black.opacity(elevated ? 0.14 : 0), radius: elevated ? 8 : 0, y: elevated ? 4 : 0)
    }
}

struct ControlSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.control, style: .continuous)
                    .fill(Color.white.opacity(0.065))
                    .overlay {
                        RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.control, style: .continuous)
                            .stroke(BatteryTruthTheme.ColorToken.border, lineWidth: 0.7)
                    }
            }
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat, elevated: Bool = false) -> some View {
        modifier(PanelSurfaceModifier(cornerRadius: cornerRadius, elevated: elevated))
    }

    func glassCapsule() -> some View {
        modifier(ControlSurfaceModifier())
    }
}
