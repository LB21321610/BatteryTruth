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
        Form {
            Section("读数说明") {
                Text("真实电量使用 AppleRawCurrentCapacity / AppleRawMaxCapacity。")
                Text("真实健康度使用 AppleRawMaxCapacity / DesignCapacity，不限制最高 100%。")
                Text("DesignCapacity 从当前 Mac 的电池控制器读取，不使用按机型硬编码的容量表。")
            }

            Section("刷新") {
                Text("主窗口每 1 秒自动刷新一次电池快照。")
            }

            Section("菜单栏显示") {
                Picker("显示样式", selection: $menuBarDisplayStyle) {
                    ForEach(MenuBarDisplayStyle.allCases) { style in
                        Text(style.title).tag(style.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("充电保护") {
                Toggle("启用充电上限监测", isOn: $chargeLimitEnabled)
                Slider(value: $chargeLimitPercent, in: 50...100, step: 1) {
                    Text("充电上限")
                } minimumValueLabel: {
                    Text("50%")
                } maximumValueLabel: {
                    Text("100%")
                }
                Text("当前上限：\(Int(chargeLimitPercent))%")
                    .foregroundStyle(.secondary)

                Toggle("启用热保护监测", isOn: $thermalProtectionEnabled)
                Slider(value: $thermalLimitCelsius, in: 30...55, step: 1) {
                    Text("热保护温度")
                } minimumValueLabel: {
                    Text("30°C")
                } maximumValueLabel: {
                    Text("55°C")
                }
                Text("当前热保护阈值：\(BatteryFormatter.temperature(thermalLimitCelsius))")
                    .foregroundStyle(.secondary)

                Button("打开系统电池设置") {
                    if let url = BatterySettingsURL.systemBatterySettings {
                        NSWorkspace.shared.open(url)
                    }
                }

                Text("本 App 不伪造充电控制。macOS Tahoe 26.4+ 且 Apple silicon 的系统级 Charge Limit 需在系统设置中启用。")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 520, height: 520)
    }
}
