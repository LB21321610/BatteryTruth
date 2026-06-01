import Foundation
import IOKit
import IOKit.ps

public struct IOKitBatteryProvider: BatteryProvider {
    public init() {}

    public func snapshot() throws -> BatterySnapshot {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else {
            return try powerSourcesSnapshot()
        }

        defer {
            IOObjectRelease(service)
        }

        let rawCurrentCapacity = intProperty("AppleRawCurrentCapacity", service: service)
        let rawMaxCapacity = intProperty("AppleRawMaxCapacity", service: service)
        let adapterDetails = dictionaryProperty("AdapterDetails", service: service)
            ?? dictionaryProperty("AppleRawAdapterDetails", service: service)
        let chargerData = dictionaryProperty("ChargerData", service: service)

        return BatterySnapshot(
            rawCurrentCapacity: rawCurrentCapacity,
            rawMaxCapacity: rawMaxCapacity,
            designCapacity: intProperty("DesignCapacity", service: service),
            systemCurrentCapacity: intProperty("CurrentCapacity", service: service),
            systemMaxCapacity: intProperty("MaxCapacity", service: service),
            cycleCount: intProperty("CycleCount", service: service),
            voltageMillivolts: intProperty("Voltage", service: service),
            amperageMilliamps: intProperty("InstantAmperage", service: service)
                ?? intProperty("Amperage", service: service),
            batteryTemperatureCelsius: temperatureCelsius(fromRaw: intProperty("Temperature", service: service)),
            virtualTemperatureCelsius: temperatureCelsius(fromRaw: intProperty("VirtualTemperature", service: service)),
            designCycleCount: intProperty("DesignCycleCount9C", service: service),
            adapterName: adapterDetails?["Name"] as? String,
            adapterWatts: intValue(adapterDetails?["Watts"]),
            adapterVoltageMillivolts: intValue(adapterDetails?["AdapterVoltage"]),
            adapterCurrentMilliamps: intValue(adapterDetails?["Current"]),
            chargingVoltageMillivolts: intValue(chargerData?["ChargingVoltage"]),
            chargingCurrentMilliamps: intValue(chargerData?["ChargingCurrent"]),
            notChargingReason: intValue(chargerData?["NotChargingReason"]),
            slowChargingReason: intValue(chargerData?["SlowChargingReason"]),
            isCharging: boolProperty("IsCharging", service: service) ?? false,
            isFullyCharged: boolProperty("FullyCharged", service: service) ?? false,
            externalConnected: boolProperty("ExternalConnected", service: service) ?? false,
            dataSource: rawCurrentCapacity != nil && rawMaxCapacity != nil ? .appleSmartBatteryRaw : .appleSmartBatterySystem,
            deviceName: stringProperty("DeviceName", service: service)
        )
    }

    private func intProperty(_ key: String, service: io_registry_entry_t) -> Int? {
        guard let value = registryProperty(key, service: service) else {
            return nil
        }

        if let number = value as? NSNumber {
            return number.intValue
        }

        return nil
    }

    private func boolProperty(_ key: String, service: io_registry_entry_t) -> Bool? {
        guard let value = registryProperty(key, service: service) else {
            return nil
        }

        if let bool = value as? Bool {
            return bool
        }

        if let number = value as? NSNumber {
            return number.boolValue
        }

        return nil
    }

    private func stringProperty(_ key: String, service: io_registry_entry_t) -> String? {
        registryProperty(key, service: service) as? String
    }

    private func dictionaryProperty(_ key: String, service: io_registry_entry_t) -> [String: Any]? {
        registryProperty(key, service: service) as? [String: Any]
    }

    private func registryProperty(_ key: String, service: io_registry_entry_t) -> Any? {
        guard let unmanaged = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        ) else {
            return nil
        }

        return unmanaged.takeRetainedValue()
    }

    private func powerSourcesSnapshot() throws -> BatterySnapshot {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            throw BatteryReadError.noBattery
        }

        guard let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else {
            throw BatteryReadError.noBattery
        }

        for source in sources {
            guard
                let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
                isBatteryDescription(description)
            else {
                continue
            }

            return BatterySnapshot(
                rawCurrentCapacity: nil,
                rawMaxCapacity: nil,
                designCapacity: intValue(description["DesignCapacity"]),
                systemCurrentCapacity: intValue(description["Current Capacity"]),
                systemMaxCapacity: intValue(description["Max Capacity"]),
                cycleCount: nil,
                voltageMillivolts: nil,
                amperageMilliamps: nil,
                batteryTemperatureCelsius: temperatureCelsius(fromRaw: intValue(description["Temperature"])),
                isCharging: boolValue(description["Is Charging"]) ?? false,
                isFullyCharged: boolValue(description["Fully Charged"]) ?? false,
                externalConnected: (description["Power Source State"] as? String) == "AC Power",
                dataSource: .powerSources,
                deviceName: description["Name"] as? String
            )
        }

        throw BatteryReadError.noBattery
    }

    private func isBatteryDescription(_ description: [String: Any]) -> Bool {
        if let type = description["Type"] as? String, type == "InternalBattery" {
            return true
        }

        if let transport = description["Transport Type"] as? String, transport == "Internal" {
            return true
        }

        return false
    }

    private func intValue(_ value: Any?) -> Int? {
        if let number = value as? NSNumber {
            return number.intValue
        }

        return nil
    }

    private func boolValue(_ value: Any?) -> Bool? {
        if let bool = value as? Bool {
            return bool
        }

        if let number = value as? NSNumber {
            return number.boolValue
        }

        return nil
    }

    private func temperatureCelsius(fromRaw rawValue: Int?) -> Double? {
        guard let rawValue else {
            return nil
        }

        if rawValue > 1000 {
            return (Double(rawValue) / 10) - 273.15
        }

        return Double(rawValue) / 10
    }
}
