import Foundation

public protocol BatteryProvider: Sendable {
    func snapshot() throws -> BatterySnapshot
}
