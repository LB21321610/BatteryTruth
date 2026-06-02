import BatteryCore
import SwiftUI

struct ContentView: View {
    @Bindable var monitor: BatteryMonitor

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppBackground()

                ScrollView(.vertical) {
                    if let snapshot = monitor.snapshot {
                        DashboardView(
                            snapshot: snapshot,
                            monitor: monitor,
                            availableWidth: proxy.size.width
                        ) {
                            monitor.refresh()
                        }
                    } else {
                        EmptyBatteryView(
                            message: monitor.errorMessage ?? "正在读取电池数据",
                            monitor: monitor
                        ) {
                            monitor.refresh()
                        }
                        .frame(maxWidth: .infinity, minHeight: max(560, proxy.size.height))
                    }
                }
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
                .background(Color.clear)
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .batteryScrollPhaseTracking { isScrolling in
                    monitor.setScrolling(isScrolling)
                }
            }
        }
    }
}

private struct DashboardView: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    let availableWidth: CGFloat
    let refresh: () -> Void
    @State private var appeared = false

    private var isWide: Bool {
        availableWidth >= 980
    }

    private var contentPadding: CGFloat {
        if availableWidth >= 1200 {
            return 36
        }
        if availableWidth <= 520 {
            return 16
        }
        return 24
    }

    private var heroWidth: CGFloat {
        max(420, availableWidth * 0.58)
    }

    var body: some View {
        LazyVStack(spacing: 18) {
            HeaderView(snapshot: snapshot, refresh: refresh)
                .reveal(appeared, delay: 0.00)

            if isWide {
                HStack(alignment: .top, spacing: 18) {
                    BatteryHeroView(snapshot: snapshot, monitor: monitor, availableWidth: heroWidth)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 18) {
                        PowerPanel(monitor: monitor)
                        ProtectionPanel(snapshot: snapshot, monitor: monitor)
                        HealthRingView(snapshot: snapshot)
                        CapacityPanel(snapshot: snapshot)
                    }
                    .frame(width: min(420, max(340, availableWidth * 0.30)))
                }
                .reveal(appeared, delay: 0.08)
            } else {
                BatteryHeroView(snapshot: snapshot, monitor: monitor, availableWidth: availableWidth)
                    .reveal(appeared, delay: 0.08)

                if availableWidth < 640 {
                    VStack(spacing: 14) {
                        PowerPanel(monitor: monitor)
                        ProtectionPanel(snapshot: snapshot, monitor: monitor)
                        HealthRingView(snapshot: snapshot)
                        CapacityPanel(snapshot: snapshot)
                    }
                    .reveal(appeared, delay: 0.16)
                } else {
                    VStack(spacing: 14) {
                        PowerPanel(monitor: monitor)
                        ProtectionPanel(snapshot: snapshot, monitor: monitor)

                        HStack(spacing: 14) {
                            HealthRingView(snapshot: snapshot)
                            CapacityPanel(snapshot: snapshot)
                        }
                    }
                    .reveal(appeared, delay: 0.16)
                }
            }

            MetricsGrid(snapshot: snapshot, monitor: monitor, availableWidth: availableWidth)
                .reveal(appeared, delay: 0.24)

            AppSettingsPanel()
                .reveal(appeared, delay: 0.28)

            FormulaPanel(snapshot: snapshot)
                .reveal(appeared, delay: 0.36)

            if snapshot.healthIsAboveDesign {
                InfoRibbon(
                    title: "满充容量高于设计容量",
                    message: "这是新电池或校准状态正常可能出现的真实读数，健康度不做 100% 截断。"
                )
            } else if !snapshot.hasRawCharge {
                InfoRibbon(
                    title: "真实容量不可用",
                    message: "当前硬件未返回 raw 容量字段，界面只展示系统百分比参考。"
                )
            } else if !snapshot.hasHealth {
                InfoRibbon(
                    title: "设计容量不可用",
                    message: "不同 Mac 机型设计容量不同；当前机器未返回 DesignCapacity，因此不使用机型表猜测健康度。"
                )
            }
        }
        .padding(contentPadding)
        .frame(maxWidth: .infinity)
        .onAppear {
            appeared = true
        }
    }
}

private struct HeaderView: View {
    let snapshot: BatterySnapshot
    let refresh: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("BatteryTruth")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)

                Text("真实容量 / 满充容量")
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: refresh) {
                Label("刷新", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .glassCapsule()
            .help("刷新电池数据")
        }
    }
}

private struct BatteryHeroView: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    let availableWidth: CGFloat

    private var percent: Double {
        snapshot.trueChargePercent ?? snapshot.systemChargePercent ?? 0
    }

    private var iconWidth: CGFloat {
        min(max(availableWidth * 0.42, 250), 540)
    }

    private var iconHeight: CGFloat {
        min(max(iconWidth * 0.50, 126), 220)
    }

    private var percentFontSize: CGFloat {
        min(max(availableWidth * 0.07, 46), 76)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(BatteryFormatter.compactPercent(snapshot.trueChargePercent ?? snapshot.systemChargePercent))
                    .font(.system(size: percentFontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.45, dampingFraction: 0.82), value: snapshot.trueChargePercent ?? snapshot.systemChargePercent ?? 0)

                Text("%")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            VisualBatteryIcon(percent: percent, isCharging: snapshot.isCharging)
                .frame(width: iconWidth, height: iconHeight)

            HStack(spacing: 8) {
                Image(systemName: snapshot.isCharging ? "bolt.fill" : "powerplug")
                    .symbolRenderingMode(.hierarchical)
                Text(snapshot.statusText)
                    .fontWeight(.semibold)
                LastRefreshText(monitor: monitor, fallback: snapshot.timestamp)
            }
            .font(.system(.callout, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassCapsule()
        }
        .padding(.vertical, availableWidth >= 980 ? 30 : 18)
        .frame(maxWidth: .infinity)
        .glassPanel(cornerRadius: 28)
    }
}

private struct LastRefreshText: View {
    let monitor: BatteryMonitor
    let fallback: Date

    var body: some View {
        Text("刷新 \(BatteryFormatter.timestamp(monitor.lastRefresh ?? fallback))")
            .foregroundStyle(.secondary)
            .monospacedDigit()
    }
}

private struct VisualBatteryIcon: View {
    let percent: Double
    let isCharging: Bool
    @State private var pulse = false

    private var normalized: Double {
        min(max(percent / 100, 0), 1)
    }

    private var fillColor: Color {
        switch percent {
        case ..<20:
            return Color(red: 1.0, green: 0.34, blue: 0.25)
        case ..<50:
            return Color(red: 1.0, green: 0.72, blue: 0.28)
        default:
            return Color(red: 0.27, green: 0.93, blue: 0.63)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let capWidth = proxy.size.width * 0.07
            let bodyWidth = proxy.size.width - capWidth - 8
            let inset: CGFloat = 10
            let fillWidth = max(10, (bodyWidth - inset * 2) * normalized)

            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.45), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.black.opacity(0.16))
                        )

                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    fillColor.opacity(0.92),
                                    fillColor.opacity(0.58),
                                    .white.opacity(0.35)
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                        .frame(width: fillWidth, height: proxy.size.height - inset * 2)
                        .padding(inset)
                        .shadow(color: fillColor.opacity(0.30), radius: 10, y: 4)
                        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: fillWidth)

                    LinearGradient(
                        colors: [.white.opacity(0.22), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: max(10, fillWidth), height: proxy.size.height * 0.42)
                    .padding(inset)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(.white)
                            .shadow(color: fillColor.opacity(0.75), radius: pulse ? 12 : 6)
                            .frame(width: bodyWidth, height: proxy.size.height)
                            .scaleEffect(pulse ? 1.02 : 0.96)
                            .animation(.spring(response: 0.45, dampingFraction: 0.72), value: pulse)
                    }
                }
                .frame(width: bodyWidth)

                Capsule()
                    .fill(.white.opacity(0.42))
                    .frame(width: capWidth, height: proxy.size.height * 0.42)
            }
        }
        .onAppear {
            pulse = true
        }
        .accessibilityLabel("真实电量 \(BatteryFormatter.percent(percent))")
    }
}

private struct HealthRingView: View {
    let snapshot: BatterySnapshot
    @State private var ringVisible = false

    private var health: Double {
        snapshot.healthPercent ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("真实健康度")
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.18), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: ringVisible ? min(max(health / 100, 0), 1.2) : 0)
                    .stroke(
                        AngularGradient(
                            colors: [.green, .mint, .cyan, .green],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.78), value: ringVisible)
                    .animation(.spring(response: 0.55, dampingFraction: 0.82), value: health)

                VStack(spacing: 2) {
                    Text(BatteryFormatter.compactPercent(snapshot.healthPercent))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("%")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 128, height: 128)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 22)
        .onAppear {
            ringVisible = true
        }
    }
}

private struct PowerPanel: View {
    let monitor: BatteryMonitor

    private var telemetry: BatteryTelemetry? {
        monitor.telemetry
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("实时功率", systemImage: "bolt.circle.fill")
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                PowerReadout(
                    title: "充电功率",
                    value: BatteryFormatter.power(telemetry?.chargingPowerWatts),
                    color: .green
                )

                PowerReadout(
                    title: "掉电功率",
                    value: BatteryFormatter.power(telemetry?.dischargingPowerWatts),
                    color: .orange
                )
            }

            HStack(spacing: 12) {
                PowerReadout(
                    title: "电池温度",
                    value: BatteryFormatter.temperature(telemetry?.batteryTemperatureCelsius),
                    color: .cyan
                )

                PowerReadout(
                    title: "虚拟温度",
                    value: BatteryFormatter.temperature(telemetry?.virtualTemperatureCelsius),
                    color: .teal
                )
            }

            Text("使用本机电池控制器返回的电压与实时电流计算。缺少真实字段时显示不可用。")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 22)
    }
}

private struct PowerReadout: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProtectionPanel: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    @AppStorage("chargeLimitEnabled") private var chargeLimitEnabled = true
    @AppStorage("chargeLimitPercent") private var chargeLimitPercent = 80.0
    @AppStorage("thermalProtectionEnabled") private var thermalProtectionEnabled = true
    @AppStorage("thermalLimitCelsius") private var thermalLimitCelsius = 38.0

    private var currentPercent: Double? {
        snapshot.trueChargePercent ?? snapshot.systemChargePercent
    }

    private var chargeLimitReached: Bool {
        guard chargeLimitEnabled, let currentPercent else {
            return false
        }
        return currentPercent >= chargeLimitPercent
    }

    private var thermalLimitReached: Bool {
        guard thermalProtectionEnabled, let temperature = monitor.telemetry?.batteryTemperatureCelsius else {
            return false
        }
        return temperature >= thermalLimitCelsius
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("充电保护", systemImage: "shield.lefthalf.filled")
                .font(.system(.callout, design: .rounded, weight: .bold))

            ProtectionLine(
                title: "充电上限",
                value: chargeLimitEnabled ? "\(Int(chargeLimitPercent))%" : "关闭",
                active: chargeLimitReached,
                activeText: "已达到上限"
            )

            ProtectionLine(
                title: "热保护",
                value: thermalProtectionEnabled ? BatteryFormatter.temperature(thermalLimitCelsius) : "关闭",
                active: thermalLimitReached,
                activeText: "温度过高"
            )

            Text("基于真实电量和温度判断保护状态。当前 macOS 14 专版没有本 App 可直接调用的公开切断充电接口；macOS Tahoe 26.4+ 的系统级 Charge Limit 需在系统设置中启用。")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 22)
    }
}

private struct ProtectionLine: View {
    let title: String
    let value: String
    let active: Bool
    let activeText: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(active ? activeText : "监测中")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(active ? .orange : .secondary)
            }
            Spacer()
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
        }
    }
}

private struct CapacityPanel: View {
    let snapshot: BatterySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            MetricLine(title: "当前容量", value: BatteryFormatter.capacity(snapshot.rawCurrentCapacity))
            MetricLine(title: "满充容量", value: BatteryFormatter.capacity(snapshot.rawMaxCapacity))
            MetricLine(title: "设计容量", value: BatteryFormatter.capacity(snapshot.designCapacity))
            MetricLine(title: "系统参考", value: BatteryFormatter.percent(snapshot.systemChargePercent))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 164, alignment: .leading)
        .glassPanel(cornerRadius: 22)
    }
}

private struct MetricsGrid: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    let availableWidth: CGFloat

    private var columns: [GridItem] {
        let minimum = availableWidth >= 980 ? 220.0 : 150.0
        return [GridItem(.adaptive(minimum: minimum), spacing: 12)]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            SmallMetric(title: "循环次数", value: snapshot.cycleCount.map(String.init) ?? "--")
            SmallMetric(title: "设计循环", value: snapshot.designCycleCount.map(String.init) ?? "--")
            SmallMetric(title: "循环损耗", value: BatteryFormatter.percent(snapshot.cycleUsagePercent))
            SmallMetric(title: "适配器", value: snapshot.adapterWatts.map { "\($0) W" } ?? "--")
            LiveTelemetryMetrics(monitor: monitor)
            SmallMetric(title: "原始读数", value: snapshot.hasRawCharge ? "可用" : "不可用")
            SmallMetric(title: "设计容量", value: snapshot.designCapacity == nil ? "不可用" : "本机读取")
        }
    }
}

private struct LiveTelemetryMetrics: View {
    let monitor: BatteryMonitor

    private var telemetry: BatteryTelemetry? {
        monitor.telemetry
    }

    var body: some View {
        SmallMetric(title: "电压", value: telemetry?.voltageMillivolts.map { "\($0) mV" } ?? "--")
        SmallMetric(title: "电流", value: telemetry?.amperageMilliamps.map { "\($0) mA" } ?? "--")
        SmallMetric(title: "充电功率", value: BatteryFormatter.power(telemetry?.chargingPowerWatts))
        SmallMetric(title: "掉电功率", value: BatteryFormatter.power(telemetry?.dischargingPowerWatts))
        SmallMetric(title: "电池温度", value: BatteryFormatter.temperature(telemetry?.batteryTemperatureCelsius))
        SmallMetric(title: "虚拟温度", value: BatteryFormatter.temperature(telemetry?.virtualTemperatureCelsius))
    }
}

private struct FormulaPanel: View {
    let snapshot: BatterySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("计算来源", systemImage: "function")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                Spacer()
                Text(snapshot.dataSource.rawValue)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                FormulaLine(
                    title: "真实电量",
                    formula: "AppleRawCurrentCapacity / AppleRawMaxCapacity",
                    result: BatteryFormatter.percent(snapshot.trueChargePercent)
                )
                FormulaLine(
                    title: "真实健康度",
                    formula: "AppleRawMaxCapacity / DesignCapacity",
                    result: BatteryFormatter.percent(snapshot.healthPercent)
                )
                FormulaLine(
                    title: "实时功率",
                    formula: "Voltage(mV) × InstantAmperage(mA) / 1,000,000",
                    result: BatteryFormatter.power(snapshot.signedBatteryPowerWatts)
                )
                Text("DesignCapacity 来自当前 Mac 的电池控制器；不同机型不会共用固定设计容量。")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .glassPanel(cornerRadius: 22)
    }
}

private struct AppSettingsPanel: View {
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = MenuBarDisplayStyle.percent.rawValue
    @AppStorage("chargeLimitEnabled") private var chargeLimitEnabled = true
    @AppStorage("chargeLimitPercent") private var chargeLimitPercent = 80.0
    @AppStorage("thermalProtectionEnabled") private var thermalProtectionEnabled = true
    @AppStorage("thermalLimitCelsius") private var thermalLimitCelsius = 38.0
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("设置选项", systemImage: "slider.horizontal.3")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                Spacer()
                Button("系统电池设置") {
                    openSystemBatterySettings()
                }
                .buttonStyle(.plain)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glassCapsule()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("菜单栏显示")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)

                Picker("菜单栏显示", selection: $menuBarDisplayStyle) {
                    ForEach(MenuBarDisplayStyle.allCases) { style in
                        Text(style.title).tag(style.rawValue)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }

            Divider()
                .overlay(.white.opacity(0.16))

            ToggleRow(
                title: "充电上限监测",
                subtitle: "达到设定电量后在 App 内提示，不伪造系统级断电控制。",
                isOn: $chargeLimitEnabled
            )

            SettingSlider(
                title: "充电上限",
                valueText: "\(Int(chargeLimitPercent))%",
                value: $chargeLimitPercent,
                range: 50...100,
                step: 1
            )
            .disabled(!chargeLimitEnabled)
            .opacity(chargeLimitEnabled ? 1 : 0.45)

            ToggleRow(
                title: "热保护监测",
                subtitle: "基于电池控制器返回的真实温度字段判断。",
                isOn: $thermalProtectionEnabled
            )

            SettingSlider(
                title: "热保护阈值",
                valueText: BatteryFormatter.temperature(thermalLimitCelsius),
                value: $thermalLimitCelsius,
                range: 30...55,
                step: 1
            )
            .disabled(!thermalProtectionEnabled)
            .opacity(thermalProtectionEnabled ? 1 : 0.45)
        }
        .padding(18)
        .glassPanel(cornerRadius: 22)
    }

    private func openSystemBatterySettings() {
        guard let url = BatterySettingsURL.systemBatterySettings else {
            return
        }
        openURL(url)
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                Text(subtitle)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
    }
}

private struct SettingSlider: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(valueText)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step)
                .tint(.mint)
        }
    }
}

private struct FormulaLine: View {
    let title: String
    let formula: String
    let result: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(formula)
                    .font(.system(.callout, design: .monospaced, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer()

            Text(result)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
        }
    }
}

private struct MetricLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .font(.system(.callout, design: .rounded))
    }
}

private struct SmallMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 18)
    }
}

private struct InfoRibbon: View {
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.system(.footnote, design: .rounded))
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: 16)
    }
}

private struct EmptyBatteryView: View {
    let message: String
    let monitor: BatteryMonitor
    let refresh: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "battery.0percent")
                .font(.system(size: 60, weight: .light))
                .symbolRenderingMode(.hierarchical)

            Text(message)
                .font(.system(.title3, design: .rounded, weight: .semibold))

            Text("这台设备没有返回 AppleSmartBattery 数据，或当前系统拒绝读取该电池服务。")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            EmptyLastRefreshText(monitor: monitor)

            Button("重新读取", action: refresh)
                .buttonStyle(.borderedProminent)
        }
        .padding(28)
        .frame(width: 360)
        .glassPanel(cornerRadius: 26)
    }
}

private struct EmptyLastRefreshText: View {
    let monitor: BatteryMonitor

    var body: some View {
        if let lastRefresh = monitor.lastRefresh {
            Text("上次刷新 \(BatteryFormatter.timestamp(lastRefresh))")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

private struct RevealModifier: ViewModifier {
    let isVisible: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 24)
            .scaleEffect(isVisible ? 1 : 0.985)
            .animation(.spring(response: 0.7, dampingFraction: 0.82).delay(delay), value: isVisible)
    }
}

private extension View {
    func reveal(_ isVisible: Bool, delay: Double) -> some View {
        modifier(RevealModifier(isVisible: isVisible, delay: delay))
    }

    @ViewBuilder
    func batteryScrollPhaseTracking(_ onChange: @escaping (Bool) -> Void) -> some View {
        if #available(macOS 15.0, *) {
            onScrollPhaseChange { _, newPhase in
                onChange(newPhase.isScrolling)
            }
        } else {
            self
        }
    }
}
