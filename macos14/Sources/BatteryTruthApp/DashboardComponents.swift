import SwiftUI

struct DashboardSection<Content: View>: View {
    let title: String
    let systemImage: String
    let accessory: String?
    let elevated: Bool
    let content: Content

    init(
        _ title: String,
        systemImage: String,
        accessory: String? = nil,
        elevated: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.accessory = accessory
        self.elevated = elevated
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BatteryTruthTheme.Spacing.item) {
            SectionHeader(title: title, systemImage: systemImage, accessory: accessory)
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: BatteryTruthTheme.Radius.panel, elevated: elevated)
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    let accessory: String?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                .frame(width: 16)

            Text(title)
                .font(BatteryTruthTheme.Font.section)
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            if let accessory {
                Text(accessory)
                    .font(BatteryTruthTheme.Font.label)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}

struct DashboardGrid<Content: View>: View {
    let availableWidth: CGFloat
    let minimumColumnWidth: CGFloat
    let spacing: CGFloat
    let content: Content

    init(
        availableWidth: CGFloat,
        minimumColumnWidth: CGFloat? = nil,
        spacing: CGFloat = BatteryTruthTheme.Spacing.item,
        @ViewBuilder content: () -> Content
    ) {
        self.availableWidth = availableWidth
        self.minimumColumnWidth = minimumColumnWidth ?? (availableWidth >= 980 ? 188 : 150)
        self.spacing = spacing
        self.content = content()
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: minimumColumnWidth), spacing: spacing)]
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
            content
        }
    }
}

struct MetricCard: View {
    let metric: DashboardMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                if let systemImage = metric.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(metric.status.color)
                }

                Text(metric.title)
                    .font(BatteryTruthTheme.Font.label)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text(metric.value)
                .font(BatteryTruthTheme.Font.value)
                .foregroundStyle(metric.status == .unavailable ? BatteryTruthTheme.ColorToken.textSecondary : .primary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            if let subtitle = metric.subtitle {
                Text(subtitle)
                    .font(BatteryTruthTheme.Font.footnote)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.card, style: .continuous)
                .fill(BatteryTruthTheme.ColorToken.card)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(BatteryTruthTheme.ColorToken.highlight.opacity(0.70))
                        .frame(height: 1)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.card, style: .continuous)
                        .stroke(BatteryTruthTheme.ColorToken.hairline, lineWidth: 0.7)
                }
        }
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let subtitle: String?
    let status: DashboardStatusStyle

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        status: DashboardStatusStyle = .neutral
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.status = status
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BatteryTruthTheme.Font.footnote)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }

            Spacer(minLength: 12)

            Text(value)
                .font(BatteryTruthTheme.Font.mono)
                .foregroundStyle(status == .unavailable ? BatteryTruthTheme.ColorToken.textSecondary : .primary)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.64)
        }
        .padding(.vertical, 4)
    }
}

struct StatusPill: View {
    let text: String
    let style: DashboardStatusStyle
    let systemImage: String?

    init(_ text: String, style: DashboardStatusStyle, systemImage: String? = nil) {
        self.text = text
        self.style = style
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage ?? style.symbolName)
                .font(.system(size: 11, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
            Text(text)
                .font(.system(.caption, design: .default, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(style.color)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(style.color.opacity(0.105))
                .overlay {
                    Capsule()
                        .stroke(style.color.opacity(0.28), lineWidth: 0.7)
                }
        }
    }
}

struct DashboardDivider: View {
    var body: some View {
        Rectangle()
            .fill(BatteryTruthTheme.ColorToken.hairline)
            .frame(height: 1)
    }
}

struct ToolbarIconButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .glassCapsule()
        .help(title)
    }
}
