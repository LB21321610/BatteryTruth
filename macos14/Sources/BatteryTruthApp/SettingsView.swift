import AppKit
import BatteryCore
import SwiftUI

struct SettingsView: View {
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = MenuBarDisplayStyle.percent.rawValue
    @AppStorage("chargeLimitEnabled") private var chargeLimitEnabled = true
    @AppStorage("chargeLimitPercent") private var chargeLimitPercent = 80.0
    @AppStorage("thermalProtectionEnabled") private var thermalProtectionEnabled = true
    @AppStorage("thermalLimitCelsius") private var thermalLimitCelsius = 38.0

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 12) {
                    SettingsTitle()

                    DashboardSection("Menu Bar", systemImage: "menubar.rectangle") {
                        Picker("显示样式", selection: $menuBarDisplayStyle) {
                            ForEach(MenuBarDisplayStyle.allCases) { style in
                                Text(style.title).tag(style.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    DashboardSection("Battery Protection", systemImage: "shield.lefthalf.filled") {
                        PreferencesToggleRow(
                            title: "启用充电上限监测",
                            subtitle: "达到设定电量后在 App 内提示，不伪造系统级断电控制。",
                            isOn: $chargeLimitEnabled
                        )

                        PreferencesSlider(
                            title: "充电上限",
                            valueText: "\(Int(chargeLimitPercent))%",
                            value: $chargeLimitPercent,
                            range: 50...100,
                            step: 1,
                            minimumLabel: "50%",
                            maximumLabel: "100%"
                        )
                        .disabled(!chargeLimitEnabled)
                        .opacity(chargeLimitEnabled ? 1 : 0.46)

                        DashboardDivider()

                        PreferencesToggleRow(
                            title: "启用热保护监测",
                            subtitle: "基于电池控制器返回的真实温度字段判断。",
                            isOn: $thermalProtectionEnabled
                        )

                        PreferencesSlider(
                            title: "热保护温度",
                            valueText: BatteryFormatter.temperature(thermalLimitCelsius),
                            value: $thermalLimitCelsius,
                            range: 30...55,
                            step: 1,
                            minimumLabel: "30°C",
                            maximumLabel: "55°C"
                        )
                        .disabled(!thermalProtectionEnabled)
                        .opacity(thermalProtectionEnabled ? 1 : 0.46)
                    }

                    DashboardSection("System Integration", systemImage: "gearshape.2") {
                        Button("打开系统电池设置") {
                            if let url = BatterySettingsURL.systemBatterySettings {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .font(.system(.footnote, design: .default, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .buttonStyle(LiquidGlassButtonStyle())

                        Text("本 App 不伪造充电控制。macOS Tahoe 26.4+ 且 Apple silicon 的系统级 Charge Limit 需在系统设置中启用。")
                            .font(BatteryTruthTheme.Font.footnote)
                            .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    DashboardSection("Diagnostics", systemImage: "doc.text.magnifyingglass") {
                        MetricRow(title: "主窗口刷新", value: "每 1 秒")
                        MetricRow(title: "诊断信息复制", value: "Battery 菜单")
                        Text("诊断信息复制继续使用主窗口和菜单栏共享的当前电池快照，不在设置窗口创建新的读取流程。")
                            .font(BatteryTruthTheme.Font.footnote)
                            .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    DashboardSection("Reading Model", systemImage: "function") {
                        MetricRow(title: "真实电量", value: "Raw / Max", subtitle: "AppleRawCurrentCapacity / AppleRawMaxCapacity")
                        MetricRow(title: "真实健康度", value: "Max / Design", subtitle: "AppleRawMaxCapacity / DesignCapacity")
                        MetricRow(title: "设计容量", value: "本机读取", subtitle: "不使用按机型硬编码的容量表")
                    }
                }
                .padding(18)
            }
            .scrollIndicators(.hidden)
        }
        .frame(width: 560, height: 560)
    }
}

private struct SettingsTitle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("BatteryTruth Settings")
                .font(BatteryTruthTheme.Font.title)
            Text("Menu bar, protection thresholds, and system integration.")
                .font(BatteryTruthTheme.Font.footnote)
                .foregroundStyle(BatteryTruthTheme.ColorToken.textSecondary)
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 2)
    }
}

private struct PreferencesToggleRow: View {
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

private struct PreferencesSlider: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let minimumLabel: String
    let maximumLabel: String

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

            Slider(value: $value, in: range, step: step) {
                Text(title)
            } minimumValueLabel: {
                Text(minimumLabel)
                    .font(BatteryTruthTheme.Font.label)
            } maximumValueLabel: {
                Text(maximumLabel)
                    .font(BatteryTruthTheme.Font.label)
            }
            .tint(BatteryTruthTheme.ColorToken.accent)
        }
    }
}
