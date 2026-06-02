import Foundation

enum MenuBarDisplayStyle: String, CaseIterable, Identifiable {
    case percent
    case power
    case temperature
    case health
    case compact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .percent:
            return "真实电量"
        case .power:
            return "实时功率"
        case .temperature:
            return "电池温度"
        case .health:
            return "健康度"
        case .compact:
            return "紧凑"
        }
    }
}

enum BatterySettingsURL {
    static var systemBatterySettings: URL? {
        URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension")
    }
}
