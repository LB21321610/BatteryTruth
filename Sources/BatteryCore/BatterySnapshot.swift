import Foundation

public enum BatteryReadError: Error, Equatable, Sendable {
    case noBattery
    case missingRequiredFields([String])
}

public enum BatteryDataSource: String, Equatable, Sendable {
    case appleSmartBatteryRaw = "AppleSmartBattery raw"
    case appleSmartBatterySystem = "AppleSmartBattery system"
    case powerSources = "IOPowerSources"
}

public struct BatteryTelemetry: Equatable, Sendable {
    public let voltageMillivolts: Int?
    public let amperageMilliamps: Int?
    public let batteryTemperatureCelsius: Double?
    public let virtualTemperatureCelsius: Double?
    public let timestamp: Date

    public init(
        voltageMillivolts: Int?,
        amperageMilliamps: Int?,
        batteryTemperatureCelsius: Double? = nil,
        virtualTemperatureCelsius: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.voltageMillivolts = voltageMillivolts
        self.amperageMilliamps = amperageMilliamps
        self.batteryTemperatureCelsius = batteryTemperatureCelsius
        self.virtualTemperatureCelsius = virtualTemperatureCelsius
        self.timestamp = timestamp
    }

    public init(snapshot: BatterySnapshot, timestamp: Date = Date()) {
        self.init(
            voltageMillivolts: snapshot.voltageMillivolts,
            amperageMilliamps: snapshot.amperageMilliamps,
            batteryTemperatureCelsius: snapshot.batteryTemperatureCelsius,
            virtualTemperatureCelsius: snapshot.virtualTemperatureCelsius,
            timestamp: timestamp
        )
    }

    public var signedBatteryPowerWatts: Double? {
        guard
            let voltageMillivolts,
            let amperageMilliamps
        else {
            return nil
        }

        return (Double(voltageMillivolts) * Double(amperageMilliamps)) / 1_000_000
    }

    public var chargingPowerWatts: Double? {
        guard let signedBatteryPowerWatts else {
            return nil
        }

        return max(signedBatteryPowerWatts, 0)
    }

    public var dischargingPowerWatts: Double? {
        guard let signedBatteryPowerWatts else {
            return nil
        }

        return max(-signedBatteryPowerWatts, 0)
    }
}

public struct BatterySnapshot: Equatable, Sendable {
    public let rawCurrentCapacity: Int?
    public let rawMaxCapacity: Int?
    public let designCapacity: Int?
    public let systemCurrentCapacity: Int?
    public let systemMaxCapacity: Int?
    public let cycleCount: Int?
    public let voltageMillivolts: Int?
    public let amperageMilliamps: Int?
    public let batteryTemperatureCelsius: Double?
    public let virtualTemperatureCelsius: Double?
    public let designCycleCount: Int?
    public let adapterName: String?
    public let adapterWatts: Int?
    public let adapterVoltageMillivolts: Int?
    public let adapterCurrentMilliamps: Int?
    public let chargingVoltageMillivolts: Int?
    public let chargingCurrentMilliamps: Int?
    public let notChargingReason: Int?
    public let slowChargingReason: Int?
    public let isCharging: Bool
    public let isFullyCharged: Bool
    public let externalConnected: Bool
    public let dataSource: BatteryDataSource
    public let deviceName: String?
    public let timestamp: Date

    public init(
        rawCurrentCapacity: Int?,
        rawMaxCapacity: Int?,
        designCapacity: Int?,
        systemCurrentCapacity: Int?,
        systemMaxCapacity: Int?,
        cycleCount: Int?,
        voltageMillivolts: Int?,
        amperageMilliamps: Int?,
        batteryTemperatureCelsius: Double? = nil,
        virtualTemperatureCelsius: Double? = nil,
        designCycleCount: Int? = nil,
        adapterName: String? = nil,
        adapterWatts: Int? = nil,
        adapterVoltageMillivolts: Int? = nil,
        adapterCurrentMilliamps: Int? = nil,
        chargingVoltageMillivolts: Int? = nil,
        chargingCurrentMilliamps: Int? = nil,
        notChargingReason: Int? = nil,
        slowChargingReason: Int? = nil,
        isCharging: Bool,
        isFullyCharged: Bool,
        externalConnected: Bool,
        dataSource: BatteryDataSource = .appleSmartBatteryRaw,
        deviceName: String? = nil,
        timestamp: Date = Date()
    ) {
        self.rawCurrentCapacity = rawCurrentCapacity
        self.rawMaxCapacity = rawMaxCapacity
        self.designCapacity = designCapacity
        self.systemCurrentCapacity = systemCurrentCapacity
        self.systemMaxCapacity = systemMaxCapacity
        self.cycleCount = cycleCount
        self.voltageMillivolts = voltageMillivolts
        self.amperageMilliamps = amperageMilliamps
        self.batteryTemperatureCelsius = batteryTemperatureCelsius
        self.virtualTemperatureCelsius = virtualTemperatureCelsius
        self.designCycleCount = designCycleCount
        self.adapterName = adapterName
        self.adapterWatts = adapterWatts
        self.adapterVoltageMillivolts = adapterVoltageMillivolts
        self.adapterCurrentMilliamps = adapterCurrentMilliamps
        self.chargingVoltageMillivolts = chargingVoltageMillivolts
        self.chargingCurrentMilliamps = chargingCurrentMilliamps
        self.notChargingReason = notChargingReason
        self.slowChargingReason = slowChargingReason
        self.isCharging = isCharging
        self.isFullyCharged = isFullyCharged
        self.externalConnected = externalConnected
        self.dataSource = dataSource
        self.deviceName = deviceName
        self.timestamp = timestamp
    }

    public var trueChargePercent: Double? {
        Self.percent(numerator: rawCurrentCapacity, denominator: rawMaxCapacity)
    }

    public var healthPercent: Double? {
        Self.percent(numerator: rawMaxCapacity, denominator: designCapacity)
    }

    public var systemChargePercent: Double? {
        Self.percent(numerator: systemCurrentCapacity, denominator: systemMaxCapacity)
    }

    public var signedBatteryPowerWatts: Double? {
        BatteryTelemetry(snapshot: self).signedBatteryPowerWatts
    }

    public var chargingPowerWatts: Double? {
        BatteryTelemetry(snapshot: self).chargingPowerWatts
    }

    public var dischargingPowerWatts: Double? {
        BatteryTelemetry(snapshot: self).dischargingPowerWatts
    }

    public var hasRawCharge: Bool {
        trueChargePercent != nil
    }

    public var hasHealth: Bool {
        healthPercent != nil
    }

    public var healthIsAboveDesign: Bool {
        guard let healthPercent else { return false }
        return healthPercent > 100
    }

    public var cycleUsagePercent: Double? {
        Self.percent(numerator: cycleCount, denominator: designCycleCount)
    }

    public var statusText: String {
        if isFullyCharged {
            return "已充满"
        }
        if isCharging {
            return "正在充电"
        }
        if externalConnected {
            return "已连接电源"
        }
        return "使用电池"
    }

    public var diagnosticText: String {
        let lines = [
            "BatteryTruth diagnostics",
            "True charge: \(BatteryFormatter.percent(trueChargePercent))",
            "Health: \(BatteryFormatter.percent(healthPercent))",
            "Raw current capacity: \(BatteryFormatter.capacity(rawCurrentCapacity))",
            "Raw full charge capacity: \(BatteryFormatter.capacity(rawMaxCapacity))",
            "Design capacity: \(BatteryFormatter.capacity(designCapacity))",
            "System capacity: \(BatteryFormatter.percent(systemChargePercent))",
            "Cycle count: \(cycleCount.map(String.init) ?? "Unavailable")",
            "Voltage: \(voltageMillivolts.map { "\($0) mV" } ?? "Unavailable")",
            "Amperage: \(amperageMilliamps.map { "\($0) mA" } ?? "Unavailable")",
            "Battery temperature: \(BatteryFormatter.temperature(batteryTemperatureCelsius))",
            "Virtual temperature: \(BatteryFormatter.temperature(virtualTemperatureCelsius))",
            "Signed battery power: \(BatteryFormatter.power(signedBatteryPowerWatts))",
            "Charging power: \(BatteryFormatter.power(chargingPowerWatts))",
            "Discharging power: \(BatteryFormatter.power(dischargingPowerWatts))",
            "Adapter: \(adapterName ?? "Unavailable")",
            "Adapter watts: \(adapterWatts.map { "\($0) W" } ?? "Unavailable")",
            "Design cycle count: \(designCycleCount.map(String.init) ?? "Unavailable")",
            "Status: \(statusText)",
            "Data source: \(dataSource.rawValue)",
            "Device name: \(deviceName ?? "Unavailable")",
            "Updated: \(BatteryFormatter.timestamp(timestamp))"
        ]

        return lines.joined(separator: "\n")
    }

    public func hasSameReading(as other: BatterySnapshot) -> Bool {
        hasSameDashboardReading(as: other)
            && voltageMillivolts == other.voltageMillivolts
            && amperageMilliamps == other.amperageMilliamps
    }

    public func hasSameDashboardReading(as other: BatterySnapshot) -> Bool {
        rawCurrentCapacity == other.rawCurrentCapacity
            && rawMaxCapacity == other.rawMaxCapacity
            && designCapacity == other.designCapacity
            && systemCurrentCapacity == other.systemCurrentCapacity
            && systemMaxCapacity == other.systemMaxCapacity
            && cycleCount == other.cycleCount
            && designCycleCount == other.designCycleCount
            && isCharging == other.isCharging
            && isFullyCharged == other.isFullyCharged
            && externalConnected == other.externalConnected
            && dataSource == other.dataSource
            && deviceName == other.deviceName
    }

    private static func percent(numerator: Int?, denominator: Int?) -> Double? {
        guard
            let numerator,
            let denominator,
            numerator >= 0,
            denominator > 0
        else {
            return nil
        }

        return (Double(numerator) / Double(denominator)) * 100
    }
}
