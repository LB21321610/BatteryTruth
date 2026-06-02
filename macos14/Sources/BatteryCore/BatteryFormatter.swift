import Foundation

public enum BatteryFormatter {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    public static func percent(_ value: Double?) -> String {
        guard let value, value.isFinite else {
            return "不可用"
        }

        return String(format: "%.2f%%", value)
    }

    public static func compactPercent(_ value: Double?) -> String {
        guard let value, value.isFinite else {
            return "--"
        }

        return String(format: "%.2f", value)
    }

    public static func capacity(_ value: Int?) -> String {
        guard let value else {
            return "不可用"
        }

        return "\(value) mAh"
    }

    public static func power(_ value: Double?) -> String {
        guard let value, value.isFinite else {
            return "不可用"
        }

        return String(format: "%.2f W", value)
    }

    public static func temperature(_ value: Double?) -> String {
        guard let value, value.isFinite else {
            return "不可用"
        }

        return String(format: "%.1f °C", value)
    }

    public static func timestamp(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
