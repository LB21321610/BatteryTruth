import BatteryCore
import Foundation
import Testing

@Suite("BatterySnapshot")
struct BatterySnapshotTests {
    @Test("calculates raw charge and health with fractional precision")
    func calculatesRawChargeAndHealth() {
        let snapshot = BatterySnapshot(
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
            timestamp: Date(timeIntervalSince1970: 0)
        )

        #expect(snapshot.trueChargePercent != nil)
        #expect(abs(snapshot.trueChargePercent! - 67.00387430047353) < 0.000001)
        #expect(abs(snapshot.healthPercent! - 100.367249946) < 0.000001)
        #expect(BatteryFormatter.percent(snapshot.trueChargePercent) == "67.00%")
        #expect(BatteryFormatter.percent(snapshot.healthPercent) == "100.37%")
        #expect(snapshot.healthIsAboveDesign)
    }

    @Test("does not cap health above one hundred percent")
    func healthCanExceedOneHundred() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 900,
            rawMaxCapacity: 5100,
            designCapacity: 5000,
            systemCurrentCapacity: 18,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: nil,
            amperageMilliamps: nil,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(snapshot.healthPercent == 102)
        #expect(snapshot.healthIsAboveDesign)
    }

    @Test("missing raw capacity does not invent a true charge")
    func missingRawCapacityFallsBackOnlyForSystemReference() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: nil,
            rawMaxCapacity: nil,
            designCapacity: 5000,
            systemCurrentCapacity: 42,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: nil,
            amperageMilliamps: nil,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(snapshot.trueChargePercent == nil)
        #expect(snapshot.systemChargePercent == 42)
        #expect(!snapshot.hasRawCharge)
    }

    @Test("invalid denominators never divide by zero")
    func invalidDenominatorsReturnNil() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 100,
            rawMaxCapacity: 0,
            designCapacity: 0,
            systemCurrentCapacity: 60,
            systemMaxCapacity: 0,
            cycleCount: nil,
            voltageMillivolts: nil,
            amperageMilliamps: nil,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(snapshot.trueChargePercent == nil)
        #expect(snapshot.healthPercent == nil)
        #expect(snapshot.systemChargePercent == nil)
    }

    @Test("missing design capacity does not guess health from a model table")
    func missingDesignCapacityDoesNotGuessHealth() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 4500,
            designCapacity: nil,
            systemCurrentCapacity: 22,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: nil,
            amperageMilliamps: nil,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false,
            dataSource: .appleSmartBatteryRaw
        )

        #expect(snapshot.trueChargePercent != nil)
        #expect(snapshot.healthPercent == nil)
        #expect(!snapshot.hasHealth)
    }

    @Test("positive current reports charging power only")
    func positiveCurrentReportsChargingPowerOnly() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: 12_000,
            amperageMilliamps: 2_000,
            isCharging: true,
            isFullyCharged: false,
            externalConnected: true
        )

        #expect(snapshot.signedBatteryPowerWatts == 24)
        #expect(snapshot.chargingPowerWatts == 24)
        #expect(snapshot.dischargingPowerWatts == 0)
        #expect(BatteryFormatter.power(snapshot.chargingPowerWatts) == "24.00 W")
    }

    @Test("negative current reports discharging power only")
    func negativeCurrentReportsDischargingPowerOnly() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: 12_000,
            amperageMilliamps: -500,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(snapshot.signedBatteryPowerWatts == -6)
        #expect(snapshot.chargingPowerWatts == 0)
        #expect(snapshot.dischargingPowerWatts == 6)
        #expect(BatteryFormatter.power(snapshot.dischargingPowerWatts) == "6.00 W")
    }

    @Test("missing voltage or current does not invent power")
    func missingVoltageOrCurrentDoesNotInventPower() {
        let snapshot = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: nil,
            voltageMillivolts: nil,
            amperageMilliamps: -500,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(snapshot.signedBatteryPowerWatts == nil)
        #expect(snapshot.chargingPowerWatts == nil)
        #expect(snapshot.dischargingPowerWatts == nil)
        #expect(BatteryFormatter.power(snapshot.signedBatteryPowerWatts) == "不可用")
    }

    @Test("no battery error is explicit")
    func noBatteryErrorIsExplicit() {
        #expect(BatteryReadError.noBattery == .noBattery)
    }

    @Test("same reading ignores timestamp changes")
    func sameReadingIgnoresTimestampChanges() {
        let first = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: 7,
            voltageMillivolts: 12000,
            amperageMilliamps: -500,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false,
            timestamp: Date(timeIntervalSince1970: 1)
        )
        let second = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: 7,
            voltageMillivolts: 12000,
            amperageMilliamps: -500,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false,
            timestamp: Date(timeIntervalSince1970: 2)
        )

        #expect(first.hasSameReading(as: second))
        #expect(first.hasSameDashboardReading(as: second))
        #expect(first != second)
    }

    @Test("dashboard reading ignores telemetry-only changes")
    func dashboardReadingIgnoresTelemetryOnlyChanges() {
        let first = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: 7,
            voltageMillivolts: 12000,
            amperageMilliamps: -500,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )
        let second = BatterySnapshot(
            rawCurrentCapacity: 1000,
            rawMaxCapacity: 2000,
            designCapacity: 2100,
            systemCurrentCapacity: 50,
            systemMaxCapacity: 100,
            cycleCount: 7,
            voltageMillivolts: 12100,
            amperageMilliamps: -650,
            isCharging: false,
            isFullyCharged: false,
            externalConnected: false
        )

        #expect(first.hasSameDashboardReading(as: second))
        #expect(!first.hasSameReading(as: second))
    }
}
