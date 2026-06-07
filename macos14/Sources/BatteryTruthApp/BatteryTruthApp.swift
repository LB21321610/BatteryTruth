import AppKit
import BatteryCore
import SwiftUI

@main
struct BatteryTruthApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var monitor = BatteryMonitor(provider: IOKitBatteryProvider())
    @AppStorage("menuBarDisplayStyle") private var menuBarDisplayStyle = MenuBarDisplayStyle.percent.rawValue

    var body: some Scene {
        WindowGroup("BatteryTruth") {
            ContentView(monitor: monitor)
                .frame(minWidth: 360, minHeight: 520)
                .preferredColorScheme(.dark)
                .background(WindowChromeConfigurator())
                .onAppear {
                    monitor.start()
                }
        }
        .defaultSize(width: 980, height: 760)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Battery") {
                Button("刷新") {
                    monitor.refresh()
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("复制诊断信息") {
                    monitor.copyDiagnostics()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
        }

        MenuBarExtra {
            MenuBarContentView(monitor: monitor)
        } label: {
            MenuBarLabelView(
                snapshot: monitor.snapshot,
                telemetry: monitor.telemetry,
                style: MenuBarDisplayStyle(rawValue: menuBarDisplayStyle) ?? .percent
            )
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct WindowChromeConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configure(window: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = true
        window.backgroundColor = NSColor(red: 0.055, green: 0.058, blue: 0.064, alpha: 1)
        window.styleMask.insert(.fullSizeContentView)
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.isOpaque = true
        window.contentView?.layer?.backgroundColor = NSColor(red: 0.055, green: 0.058, blue: 0.064, alpha: 1).cgColor
    }
}

private struct MenuBarLabelView: View {
    let snapshot: BatterySnapshot?
    let telemetry: BatteryTelemetry?
    let style: MenuBarDisplayStyle

    var body: some View {
        Label(labelText, systemImage: labelIcon)
    }

    private var labelText: String {
        guard let snapshot else {
            return "--"
        }

        switch style {
        case .percent:
            return BatteryFormatter.percent(snapshot.trueChargePercent ?? snapshot.systemChargePercent)
        case .power:
            return BatteryFormatter.power(telemetry?.signedBatteryPowerWatts)
        case .temperature:
            return BatteryFormatter.temperature(telemetry?.batteryTemperatureCelsius)
        case .health:
            return BatteryFormatter.percent(snapshot.healthPercent)
        case .compact:
            return BatteryFormatter.compactPercent(snapshot.trueChargePercent ?? snapshot.systemChargePercent) + "%"
        }
    }

    private var labelIcon: String {
        guard let snapshot else {
            return "battery.0percent"
        }

        if snapshot.isCharging {
            return "battery.100percent.bolt"
        }

        let percent = snapshot.trueChargePercent ?? snapshot.systemChargePercent ?? 0
        switch percent {
        case ..<25:
            return "battery.25percent"
        case ..<75:
            return "battery.50percent"
        default:
            return "battery.100percent"
        }
    }
}

private struct MenuBarContentView: View {
    let monitor: BatteryMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let snapshot = monitor.snapshot {
                Text("真实电量 \(BatteryFormatter.percent(snapshot.trueChargePercent ?? snapshot.systemChargePercent))")
                Text("健康度 \(BatteryFormatter.percent(snapshot.healthPercent))")
                Text("温度 \(BatteryFormatter.temperature(monitor.telemetry?.batteryTemperatureCelsius))")
                Text("功率 \(BatteryFormatter.power(monitor.telemetry?.signedBatteryPowerWatts))")
            } else {
                Text(monitor.errorMessage ?? "未读取到电池")
            }

            Divider()

            Button("刷新") {
                monitor.refresh()
            }

            Button("打开主窗口") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }

            Button("退出 BatteryTruth") {
                NSApp.terminate(nil)
            }
        }
        .padding(6)
        .onAppear {
            monitor.start()
        }
    }
}
