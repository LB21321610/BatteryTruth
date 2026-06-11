import SwiftUI

enum BatteryTruthTheme {
    enum ColorToken {
        static let windowTop = Color(red: 0.980, green: 0.980, blue: 0.988)
        static let windowMid = Color(red: 0.965, green: 0.968, blue: 0.976)
        static let windowBottom = Color(red: 0.944, green: 0.948, blue: 0.958)
        static let glassTint = Color(red: 0.000, green: 0.447, blue: 1.000)
        static let glassWarmEdge = Color.white
        static let panel = Color.white.opacity(0.82)
        static let panelElevated = Color.white.opacity(0.92)
        static let card = Color.white.opacity(0.76)
        static let border = Color.black.opacity(0.085)
        static let hairline = Color.black.opacity(0.055)
        static let highlight = Color.white.opacity(0.88)
        static let innerGlow = Color(red: 0.000, green: 0.447, blue: 1.000).opacity(0.045)
        static let textSecondary = Color.black.opacity(0.58)
        static let textTertiary = Color.black.opacity(0.36)
        static let normal = Color(red: 0.000, green: 0.620, blue: 0.290)
        static let warning = Color(red: 0.930, green: 0.540, blue: 0.000)
        static let critical = Color(red: 0.920, green: 0.150, blue: 0.120)
        static let accent = Color(red: 0.000, green: 0.447, blue: 1.000)
        static let unavailable = Color.black.opacity(0.36)
    }

    enum Radius {
        static let panel: CGFloat = 28
        static let card: CGFloat = 20
        static let control: CGFloat = 17
        static let pill: CGFloat = 20
    }

    enum Spacing {
        static let page: CGFloat = 24
        static let section: CGFloat = 18
        static let item: CGFloat = 14
        static let dense: CGFloat = 8
    }

    enum Font {
        static let title = SwiftUI.Font.system(.title2, design: .default, weight: .semibold)
        static let section = SwiftUI.Font.system(.title3, design: .default, weight: .semibold)
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
                BatteryTruthTheme.ColorToken.windowMid,
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

enum LiquidGlassSurfaceStyle: Equatable {
    case panel
    case elevated
    case card
    case control
    case pill(DashboardStatusStyle)

    var fallbackFill: Color {
        switch self {
        case .panel:
            return BatteryTruthTheme.ColorToken.panel
        case .elevated:
            return BatteryTruthTheme.ColorToken.panelElevated
        case .card:
            return BatteryTruthTheme.ColorToken.card
        case .control:
            return Color.white.opacity(0.070)
        case .pill(let status):
            return status.color.opacity(0.115)
        }
    }

    var edgeColor: Color {
        switch self {
        case .pill(let status):
            return status.color.opacity(0.34)
        case .elevated:
            return BatteryTruthTheme.ColorToken.glassTint.opacity(0.22)
        default:
            return BatteryTruthTheme.ColorToken.border
        }
    }

    var nativeTint: Color? {
        switch self {
        case .pill(let status):
            return status.color.opacity(0.28)
        case .control:
            return BatteryTruthTheme.ColorToken.glassTint.opacity(0.18)
        case .elevated:
            return BatteryTruthTheme.ColorToken.glassTint.opacity(0.16)
        case .panel:
            return BatteryTruthTheme.ColorToken.glassTint.opacity(0.10)
        case .card:
            return BatteryTruthTheme.ColorToken.glassTint.opacity(0.07)
        }
    }

    var isInteractive: Bool {
        switch self {
        case .control:
            return true
        default:
            return false
        }
    }

    var usesNativeGlass: Bool {
        false
    }

    var shadow: (opacity: Double, radius: CGFloat, y: CGFloat) {
        switch self {
        case .elevated:
            return (0.12, 10, 5)
        default:
            return (0, 0, 0)
        }
    }

    var usesFallbackGlow: Bool {
        switch self {
        case .elevated:
            return true
        case .panel, .card, .control, .pill:
            return false
        }
    }

    var specularOpacity: Double {
        switch self {
        case .elevated:
            return 0.62
        case .panel:
            return 0.50
        case .card:
            return 0.42
        case .control:
            return 0.48
        case .pill:
            return 0.38
        }
    }
}

struct LiquidGlassSurface<Content: View>: View {
    let style: LiquidGlassSurfaceStyle
    let cornerRadius: CGFloat
    let content: Content

    init(
        style: LiquidGlassSurfaceStyle,
        cornerRadius: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
#if compiler(>=6.2)
        if style.usesNativeGlass, #available(macOS 26.0, *) {
            content
                .glassEffect(
                    .regular.tint(style.nativeTint).interactive(style.isInteractive),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay(alignment: .top) {
                    specularLine
                }
                .overlay {
                    border
                }
                .shadow(color: .black.opacity(style.shadow.opacity), radius: style.shadow.radius, y: style.shadow.y)
        } else {
            fallbackSurface
        }
#else
        fallbackSurface
#endif
    }

    private var fallbackSurface: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(style.fallbackFill)
                    .overlay {
                        if style.usesFallbackGlow {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            BatteryTruthTheme.ColorToken.innerGlow,
                                            .clear,
                                            .black.opacity(0.06)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .overlay(alignment: .top) {
                        specularLine
                    }
                    .overlay {
                        border
                    }
            }
            .shadow(color: .black.opacity(style.shadow.opacity), radius: style.shadow.radius, y: style.shadow.y)
    }

    private var specularLine: some View {
        Rectangle()
            .fill(BatteryTruthTheme.ColorToken.glassWarmEdge.opacity(style.specularOpacity))
            .frame(height: 1)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(style.edgeColor, lineWidth: 0.8)
    }
}

struct LiquidGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let style: LiquidGlassSurfaceStyle

    func body(content: Content) -> some View {
        LiquidGlassSurface(style: style, cornerRadius: cornerRadius) {
            content
        }
    }
}

struct LiquidGlassSurfaceGroup<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = BatteryTruthTheme.Spacing.item, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        content
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .liquidGlassSurface(.control, cornerRadius: BatteryTruthTheme.Radius.control)
    }
}

extension View {
    func liquidGlassSurface(_ style: LiquidGlassSurfaceStyle, cornerRadius: CGFloat) -> some View {
        modifier(LiquidGlassSurfaceModifier(cornerRadius: cornerRadius, style: style))
    }

    func glassPanel(cornerRadius: CGFloat, elevated: Bool = false) -> some View {
        liquidGlassSurface(elevated ? .elevated : .panel, cornerRadius: cornerRadius)
    }

    func glassCapsule() -> some View {
        liquidGlassSurface(.control, cornerRadius: BatteryTruthTheme.Radius.control)
    }
}
