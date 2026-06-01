import Foundation

public struct PreviewBatteryProvider: BatteryProvider {
    private let storedSnapshot: BatterySnapshot

    public init(snapshot: BatterySnapshot = .preview) {
        self.storedSnapshot = snapshot
    }

    public func snapshot() throws -> BatterySnapshot {
        storedSnapshot
    }
}

public extension BatterySnapshot {
    static let preview = BatterySnapshot(
        rawCurrentCapacity: 3113,
        rawMaxCapacity: 4646,
        designCapacity: 4629,
        systemCurrentCapacity: 68,
        systemMaxCapacity: 100,
        cycleCount: 51,
        voltageMillivolts: 12736,
        amperageMilliamps: 3144,
        isCharging: true,
        isFullyCharged: false,
        externalConnected: true,
        dataSource: .appleSmartBatteryRaw,
        deviceName: "MacBook Battery",
        timestamp: Date()
    )
}
