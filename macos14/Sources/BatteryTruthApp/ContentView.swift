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
                        .frame(maxWidth: .infinity, minHeight: max(520, proxy.size.height))
                        .padding(.horizontal, 18)
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
            return 24
        }
        if availableWidth <= 520 {
            return 12
        }
        return 18
    }

    private var sidebarWidth: CGFloat {
        min(380, max(310, availableWidth * 0.32))
    }

    var body: some View {
        LazyVStack(spacing: BatteryTruthTheme.Spacing.section) {
            HeaderView(snapshot: snapshot, monitor: monitor, refresh: refresh)
                .reveal(appeared, delay: 0.00)

            if isWide {
                HStack(alignment: .top, spacing: BatteryTruthTheme.Spacing.section) {
                    VStack(spacing: BatteryTruthTheme.Spacing.section) {
                        BatteryHeroView(snapshot: snapshot, monitor: monitor)
                        PowerSection(monitor: monitor, availableWidth: availableWidth)
                        RawMetricsSection(snapshot: snapshot, monitor: monitor, availableWidth: availableWidth)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: BatteryTruthTheme.Spacing.section) {
                        ProtectionSection(snapshot: snapshot, monitor: monitor)
                        BatteryHealthSection(snapshot: snapshot)
                        CapacitySection(snapshot: snapshot)
                    }
                    .frame(width: sidebarWidth)
                }
                .reveal(appeared, delay: 0.07)
            } else {
                VStack(spacing: BatteryTruthTheme.Spacing.section) {
                    BatteryHeroView(snapshot: snapshot, monitor: monitor)
                    PowerSection(monitor: monitor, availableWidth: availableWidth)
                    ProtectionSection(snapshot: snapshot, monitor: monitor)
                    BatteryHealthSection(snapshot: snapshot)
                    CapacitySection(snapshot: snapshot)
                    RawMetricsSection(snapshot: snapshot, monitor: monitor, availableWidth: availableWidth)
                }
                .reveal(appeared, delay: 0.07)
            }

            CalculationSourcesSection(snapshot: snapshot)
                .reveal(appeared, delay: 0.14)

            DashboardSettingsSection(monitor: monitor)
                .reveal(appeared, delay: 0.18)

            AdvisoryMessages(snapshot: snapshot)
                .reveal(appeared, delay: 0.22)
        }
        .padding(contentPadding)
        .frame(maxWidth: 1220)
        .frame(maxWidth: .infinity)
        .onAppear {
            appeared = true
        }
    }
}

private struct HeaderView: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    let refresh: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("BatteryTruth")
                    .font(BatteryTruthTheme.Font.title)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    StatusPill(snapshot.dataSource.rawValue, style: .neutral, systemImage: "waveform.path.ecg")
                    LastRefreshText(monitor: monitor, fallback: snapshot.timestamp)
                }
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                SettingsLink {
                    Label("App 设置", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .glassCapsule()
                .help("打开 App 设置")

                ToolbarIconButton(title: "系统电池设置", systemImage: "battery.100percent") {
                    openSystemBatterySettings()
                }

                ToolbarIconButton(title: "刷新电池数据", systemImage: "arrow.clockwise", action: refresh)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassPanel(cornerRadius: BatteryTruthTheme.Radius.panel)
    }

    private func openSystemBatterySettings() {
        guard let url = BatterySettingsURL.systemBatterySettings else {
            return
        }
        openURL(url)
    }
}

private struct LastRefreshText: View {
    let monitor: BatteryMonitor
    let fallback: Date

    var body: some View {
        Text("刷新 \(BatteryFormatter.timestamp(monitor.lastRefresh ?? fallback))")
            .font(BatteryTruthTheme.Font.label)
            .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
            .monospacedDigit()
            .lineLimit(1)
    }
}

private struct BatteryHeroView: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor

    private var percent: Double {
        snapshot.trueChargePercent ?? snapshot.systemChargePercent ?? 0
    }

    private var percentText: String {
        BatteryFormatter.compactPercent(snapshot.trueChargePercent ?? snapshot.systemChargePercent)
    }

    private var statusStyle: DashboardStatusStyle {
        if !snapshot.hasRawCharge {
            return .unavailable
        }
        if percent < 20 {
            return .critical
        }
        if percent < 50 {
            return .warning
        }
        return .normal
    }

    var body: some View {
        DashboardSection("Live Battery", systemImage: "battery.100percent", elevated: true) {
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("真实电量")
                        .font(BatteryTruthTheme.Font.label)
                        .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(percentText)
                            .font(.system(size: 70, weight: .semibold, design: .default))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)

                        Text("%")
                            .font(.system(size: 24, weight: .semibold, design: .default))
                            .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    }

                    HStack(spacing: 8) {
                        StatusPill(snapshot.statusText, style: snapshot.isCharging ? .normal : .neutral, systemImage: snapshot.isCharging ? "bolt.fill" : "powerplug")
                        StatusPill(BatteryFormatter.power(monitor.telemetry?.signedBatteryPowerWatts), style: .neutral, systemImage: "bolt.circle")
                    }

                    LastRefreshText(monitor: monitor, fallback: snapshot.timestamp)
                }

                Spacer(minLength: 8)

                PrecisionBatteryGauge(percent: percent, isCharging: snapshot.isCharging, style: statusStyle)
                    .frame(width: 220, height: 104)
                    .layoutPriority(1)
            }
        }
    }
}

private struct PrecisionBatteryGauge: View {
    let percent: Double
    let isCharging: Bool
    let style: DashboardStatusStyle

    private var normalized: Double {
        min(max(percent / 100, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let capWidth = max(9, proxy.size.width * 0.055)
            let spacing: CGFloat = 7
            let bodyWidth = proxy.size.width - capWidth - spacing
            let inset: CGFloat = 8
            let fillWidth = max(8, (bodyWidth - inset * 2) * normalized)

            HStack(spacing: spacing) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(BatteryTruthTheme.ColorToken.border, lineWidth: 1)
                        }
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(BatteryTruthTheme.ColorToken.highlight.opacity(0.85))
                                .frame(height: 1)
                        }

                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(style.color.opacity(0.82))
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.white.opacity(0.22))
                                .frame(height: max(1, (proxy.size.height - inset * 2) * 0.30))
                        }
                        .frame(width: fillWidth, height: proxy.size.height - inset * 2)
                        .padding(inset)

                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white.opacity(0.92))
                            .frame(width: bodyWidth, height: proxy.size.height)
                    }
                }
                .frame(width: bodyWidth)

                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(BatteryTruthTheme.ColorToken.border)
                    .frame(width: capWidth, height: proxy.size.height * 0.36)
            }
        }
        .accessibilityLabel("真实电量 \(BatteryFormatter.percent(percent))")
    }
}

private struct PowerSection: View {
    let monitor: BatteryMonitor
    let availableWidth: CGFloat

    private var telemetry: BatteryTelemetry? {
        monitor.telemetry
    }

    var body: some View {
        DashboardSection("Power", systemImage: "bolt.circle", accessory: "Live telemetry") {
            DashboardGrid(availableWidth: availableWidth, minimumColumnWidth: 142) {
                MetricCard(metric: DashboardMetric(title: "充电功率", value: BatteryFormatter.power(telemetry?.chargingPowerWatts), systemImage: "arrow.down.circle", status: telemetry?.chargingPowerWatts == nil ? .unavailable : .normal))
                MetricCard(metric: DashboardMetric(title: "掉电功率", value: BatteryFormatter.power(telemetry?.dischargingPowerWatts), systemImage: "arrow.up.circle", status: telemetry?.dischargingPowerWatts == nil ? .unavailable : .warning))
                MetricCard(metric: DashboardMetric(title: "电池温度", value: BatteryFormatter.temperature(telemetry?.batteryTemperatureCelsius), systemImage: "thermometer.medium", status: telemetry?.batteryTemperatureCelsius == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "虚拟温度", value: BatteryFormatter.temperature(telemetry?.virtualTemperatureCelsius), systemImage: "thermometer.variable", status: telemetry?.virtualTemperatureCelsius == nil ? .unavailable : .neutral))
            }

            Text("使用本机电池控制器返回的电压与实时电流计算。缺少真实字段时显示不可用。")
                .font(BatteryTruthTheme.Font.footnote)
                .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ProtectionSection: View {
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
        DashboardSection("Protection", systemImage: "shield.lefthalf.filled", accessory: monitor.protectionStatusText) {
            MetricRow(
                title: "充电上限",
                value: chargeLimitEnabled ? "\(Int(chargeLimitPercent))%" : "关闭",
                subtitle: chargeLimitReached ? "已达到上限" : "监测中",
                status: chargeLimitReached ? .warning : .normal
            )

            DashboardDivider()

            MetricRow(
                title: "热保护",
                value: thermalProtectionEnabled ? BatteryFormatter.temperature(thermalLimitCelsius) : "关闭",
                subtitle: thermalLimitReached ? "温度过高" : "监测中",
                status: thermalLimitReached ? .warning : .normal
            )

            HStack(spacing: 8) {
                StatusPill(monitor.chargeLimitAlertActive ? "充电上限已触发" : "充电上限未触发", style: monitor.chargeLimitAlertActive ? .warning : .normal)
                StatusPill(monitor.thermalLimitAlertActive ? "热保护已触发" : "热保护未触发", style: monitor.thermalLimitAlertActive ? .warning : .normal)
            }
            .lineLimit(1)

            Text("基于真实电量和温度判断保护状态。当前 macOS 14 专版没有本 App 可直接调用的公开切断充电接口；macOS Tahoe 26.4+ 的系统级 Charge Limit 需在系统设置中启用。")
                .font(BatteryTruthTheme.Font.footnote)
                .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BatteryHealthSection: View {
    let snapshot: BatterySnapshot
    @State private var ringVisible = false

    private var health: Double {
        snapshot.healthPercent ?? 0
    }

    private var status: DashboardStatusStyle {
        guard snapshot.healthPercent != nil else {
            return .unavailable
        }
        if snapshot.healthIsAboveDesign || health >= 80 {
            return .normal
        }
        if health >= 60 {
            return .warning
        }
        return .critical
    }

    var body: some View {
        DashboardSection("Battery Health", systemImage: "heart.text.square", accessory: snapshot.healthIsAboveDesign ? "Above design" : nil) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(BatteryTruthTheme.ColorToken.hairline, lineWidth: 12)

                    Circle()
                        .trim(from: 0, to: ringVisible ? min(max(health / 100, 0), 1.2) : 0)
                        .stroke(status.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.22), value: ringVisible)

                    VStack(spacing: 0) {
                        Text(BatteryFormatter.compactPercent(snapshot.healthPercent))
                            .font(.system(size: 27, weight: .semibold, design: .default))
                            .monospacedDigit()
                        Text("%")
                            .font(BatteryTruthTheme.Font.label)
                            .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    }
                }
                .frame(width: 112, height: 112)

                VStack(alignment: .leading, spacing: 8) {
                    StatusPill(snapshot.healthPercent == nil ? "不可用" : "真实健康度", style: status)
                    MetricRow(title: "满充容量", value: BatteryFormatter.capacity(snapshot.rawMaxCapacity))
                    MetricRow(title: "设计容量", value: BatteryFormatter.capacity(snapshot.designCapacity), status: snapshot.designCapacity == nil ? .unavailable : .neutral)
                }
            }
        }
        .onAppear {
            ringVisible = true
        }
    }
}

private struct CapacitySection: View {
    let snapshot: BatterySnapshot

    var body: some View {
        DashboardSection("Capacity", systemImage: "rectangle.stack", accessory: "mAh") {
            MetricRow(title: "当前容量", value: BatteryFormatter.capacity(snapshot.rawCurrentCapacity), status: snapshot.rawCurrentCapacity == nil ? .unavailable : .neutral)
            DashboardDivider()
            MetricRow(title: "满充容量", value: BatteryFormatter.capacity(snapshot.rawMaxCapacity), status: snapshot.rawMaxCapacity == nil ? .unavailable : .neutral)
            DashboardDivider()
            MetricRow(title: "设计容量", value: BatteryFormatter.capacity(snapshot.designCapacity), status: snapshot.designCapacity == nil ? .unavailable : .neutral)
            DashboardDivider()
            MetricRow(title: "系统参考", value: BatteryFormatter.percent(snapshot.systemChargePercent), status: snapshot.systemChargePercent == nil ? .unavailable : .neutral)
        }
    }
}

private struct RawMetricsSection: View {
    let snapshot: BatterySnapshot
    let monitor: BatteryMonitor
    let availableWidth: CGFloat

    private var telemetry: BatteryTelemetry? {
        monitor.telemetry
    }

    var body: some View {
        DashboardSection("Raw Metrics", systemImage: "tablecells", accessory: "Controller fields") {
            DashboardGrid(availableWidth: availableWidth) {
                MetricCard(metric: DashboardMetric(title: "循环次数", value: snapshot.cycleCount.map(String.init) ?? "--", systemImage: "repeat", status: snapshot.cycleCount == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "设计循环", value: snapshot.designCycleCount.map(String.init) ?? "--", systemImage: "repeat.circle", status: snapshot.designCycleCount == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "循环损耗", value: BatteryFormatter.percent(snapshot.cycleUsagePercent), systemImage: "chart.line.downtrend.xyaxis", status: snapshot.cycleUsagePercent == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "适配器", value: snapshot.adapterWatts.map { "\($0) W" } ?? "--", systemImage: "powerplug", status: snapshot.adapterWatts == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "电压", value: telemetry?.voltageMillivolts.map { "\($0) mV" } ?? "--", systemImage: "bolt.horizontal", status: telemetry?.voltageMillivolts == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "电流", value: telemetry?.amperageMilliamps.map { "\($0) mA" } ?? "--", systemImage: "waveform.path", status: telemetry?.amperageMilliamps == nil ? .unavailable : .neutral))
                MetricCard(metric: DashboardMetric(title: "原始读数", value: snapshot.hasRawCharge ? "可用" : "不可用", systemImage: "checklist.checked", status: snapshot.hasRawCharge ? .normal : .unavailable))
                MetricCard(metric: DashboardMetric(title: "设计容量", value: snapshot.designCapacity == nil ? "不可用" : "本机读取", systemImage: "internaldrive", status: snapshot.designCapacity == nil ? .unavailable : .normal))
            }
        }
    }
}

private struct CalculationSourcesSection: View {
    let snapshot: BatterySnapshot

    var body: some View {
        DashboardSection("Calculation Sources", systemImage: "function", accessory: snapshot.dataSource.rawValue) {
            MetricRow(
                title: "真实电量",
                value: BatteryFormatter.percent(snapshot.trueChargePercent),
                subtitle: "AppleRawCurrentCapacity / AppleRawMaxCapacity",
                status: snapshot.trueChargePercent == nil ? .unavailable : .neutral
            )
            DashboardDivider()
            MetricRow(
                title: "真实健康度",
                value: BatteryFormatter.percent(snapshot.healthPercent),
                subtitle: "AppleRawMaxCapacity / DesignCapacity",
                status: snapshot.healthPercent == nil ? .unavailable : .neutral
            )
            DashboardDivider()
            MetricRow(
                title: "实时功率",
                value: BatteryFormatter.power(snapshot.signedBatteryPowerWatts),
                subtitle: "Voltage(mV) × InstantAmperage(mA) / 1,000,000",
                status: snapshot.signedBatteryPowerWatts == nil ? .unavailable : .neutral
            )

            Text("DesignCapacity 来自当前 Mac 的电池控制器；不同机型不会共用固定设计容量。")
                .font(BatteryTruthTheme.Font.footnote)
                .foregroundStyle(BatteryTruthTheme.ColorToken.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DashboardSettingsSection: View {
    let monitor: BatteryMonitor
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = MenuBarDisplayStyle.percent.rawValue
    @AppStorage("chargeLimitEnabled") private var chargeLimitEnabled = true
    @AppStorage("chargeLimitPercent") private var chargeLimitPercent = 80.0
    @AppStorage("thermalProtectionEnabled") private var thermalProtectionEnabled = true
    @AppStorage("thermalLimitCelsius") private var thermalLimitCelsius = 38.0
    @Environment(\.openURL) private var openURL

    var body: some View {
        DashboardSection("Settings", systemImage: "slider.horizontal.3", accessory: "Menu Bar / Protection / Diagnostics") {
            VStack(alignment: .leading, spacing: 14) {
                SettingsGroup(title: "Menu Bar", systemImage: "menubar.rectangle") {
                    Picker("菜单栏显示", selection: $menuBarDisplayStyle) {
                        ForEach(MenuBarDisplayStyle.allCases) { style in
                            Text(style.title).tag(style.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                SettingsGroup(title: "Battery Protection", systemImage: "shield") {
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
                    .opacity(chargeLimitEnabled ? 1 : 0.46)

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
                    .opacity(thermalProtectionEnabled ? 1 : 0.46)
                }

                SettingsGroup(title: "Notifications", systemImage: "bell.badge") {
                    MetricRow(title: "提醒权限", value: monitor.notificationStatusText)
                    MetricRow(title: "保护状态", value: monitor.protectionStatusText)
                    Button("测试本地提醒") {
                        monitor.postTestNotification()
                    }
                    .buttonStyle(.plain)
                    .font(.system(.footnote, design: .default, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassCapsule()
                }

                SettingsGroup(title: "System Integration", systemImage: "gearshape.2") {
                    HStack(spacing: 8) {
                        SettingsLink {
                            Text("App 设置")
                        }
                        .buttonStyle(.plain)
                        .font(.system(.footnote, design: .default, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .glassCapsule()

                        Button("系统电池设置") {
                            openSystemBatterySettings()
                        }
                        .buttonStyle(.plain)
                        .font(.system(.footnote, design: .default, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .glassCapsule()
                    }
                }

                SettingsGroup(title: "Diagnostics", systemImage: "doc.on.clipboard") {
                    Button("复制诊断信息") {
                        monitor.copyDiagnostics()
                    }
                    .buttonStyle(.plain)
                    .font(.system(.footnote, design: .default, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassCapsule()
                }
            }
        }
    }

    private func openSystemBatterySettings() {
        guard let url = BatterySettingsURL.systemBatterySettings else {
            return
        }
        openURL(url)
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, systemImage: systemImage, accessory: nil)
            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.card, style: .continuous)
                .fill(Color.white.opacity(0.035))
                .overlay {
                    RoundedRectangle(cornerRadius: BatteryTruthTheme.Radius.card, style: .continuous)
                        .stroke(BatteryTruthTheme.ColorToken.hairline, lineWidth: 0.7)
                }
        }
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
                    .font(BatteryTruthTheme.Font.body.weight(.medium))
                Text(subtitle)
                    .font(BatteryTruthTheme.Font.footnote)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
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
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(BatteryTruthTheme.Font.label)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                Spacer()
                Text(valueText)
                    .font(BatteryTruthTheme.Font.mono)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step)
                .tint(BatteryTruthTheme.ColorToken.accent)
        }
    }
}

private struct AdvisoryMessages: View {
    let snapshot: BatterySnapshot

    var body: some View {
        VStack(spacing: BatteryTruthTheme.Spacing.item) {
            if snapshot.healthIsAboveDesign {
                InfoRibbon(
                    title: "满充容量高于设计容量",
                    message: "这是新电池或校准状态正常可能出现的真实读数，健康度不做 100% 截断。",
                    style: .normal
                )
            } else if !snapshot.hasRawCharge {
                InfoRibbon(
                    title: "真实容量不可用",
                    message: "当前硬件未返回 raw 容量字段，界面只展示系统百分比参考。",
                    style: .unavailable
                )
            } else if !snapshot.hasHealth {
                InfoRibbon(
                    title: "设计容量不可用",
                    message: "不同 Mac 机型设计容量不同；当前机器未返回 DesignCapacity，因此不使用机型表猜测健康度。",
                    style: .unavailable
                )
            }
        }
    }
}

private struct InfoRibbon: View {
    let title: String
    let message: String
    let style: DashboardStatusStyle

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: style.symbolName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(style.color)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.footnote, design: .default, weight: .semibold))
                Text(message)
                    .font(BatteryTruthTheme.Font.footnote)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(cornerRadius: BatteryTruthTheme.Radius.card)
    }
}

private struct EmptyBatteryView: View {
    let message: String
    let monitor: BatteryMonitor
    let refresh: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "battery.0percent")
                .font(.system(size: 44, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(BatteryTruthTheme.ColorToken.unavailable)

            VStack(spacing: 5) {
                Text(message)
                    .font(BatteryTruthTheme.Font.title)

                Text("这台设备没有返回 AppleSmartBattery 数据，或当前系统拒绝读取该电池服务。")
                    .font(BatteryTruthTheme.Font.body)
                    .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            EmptyLastRefreshText(monitor: monitor)

            Button("重新读取", action: refresh)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 360)
        .glassPanel(cornerRadius: BatteryTruthTheme.Radius.panel, elevated: true)
    }
}

private struct EmptyLastRefreshText: View {
    let monitor: BatteryMonitor

    var body: some View {
        if let lastRefresh = monitor.lastRefresh {
            Text("上次刷新 \(BatteryFormatter.timestamp(lastRefresh))")
                .font(BatteryTruthTheme.Font.footnote)
                .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
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
            .offset(y: isVisible ? 0 : 10)
            .animation(.easeOut(duration: 0.24).delay(delay), value: isVisible)
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
