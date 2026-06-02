import AppKit
import BatteryCore
import Foundation
import Observation

@Observable
@MainActor
final class BatteryMonitor {
    private let provider: BatteryProvider
    private var timer: Timer?
    @ObservationIgnored private var isScrolling = false
    @ObservationIgnored private var deferredSnapshot: BatterySnapshot?
    @ObservationIgnored private var deferredRefreshDate: Date?

    var snapshot: BatterySnapshot?
    var telemetry: BatteryTelemetry?
    var errorMessage: String?
    var lastRefresh: Date?

    init(provider: BatteryProvider) {
        self.provider = provider
    }

    func start() {
        refresh()

        guard timer == nil else {
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func setScrolling(_ scrolling: Bool) {
        guard isScrolling != scrolling else {
            return
        }

        isScrolling = scrolling

        if !scrolling, let deferredSnapshot, let deferredRefreshDate {
            self.deferredSnapshot = nil
            self.deferredRefreshDate = nil
            publish(snapshot: deferredSnapshot, refreshDate: deferredRefreshDate)
        }
    }

    func refresh() {
        do {
            let latestSnapshot = try provider.snapshot()
            let refreshDate = Date()

            if isScrolling {
                deferredSnapshot = latestSnapshot
                deferredRefreshDate = refreshDate
                return
            }

            publish(snapshot: latestSnapshot, refreshDate: refreshDate)
        } catch BatteryReadError.noBattery {
            snapshot = nil
            telemetry = nil
            deferredSnapshot = nil
            deferredRefreshDate = nil
            errorMessage = "未检测到内置电池"
            lastRefresh = Date()
        } catch {
            snapshot = nil
            telemetry = nil
            deferredSnapshot = nil
            deferredRefreshDate = nil
            errorMessage = "无法读取电池数据"
            lastRefresh = Date()
        }
    }

    private func publish(snapshot latestSnapshot: BatterySnapshot, refreshDate: Date) {
        telemetry = BatteryTelemetry(snapshot: latestSnapshot, timestamp: refreshDate)

        if let snapshot, snapshot.hasSameDashboardReading(as: latestSnapshot) {
            lastRefresh = refreshDate
            errorMessage = nil
            return
        }

        snapshot = latestSnapshot
        errorMessage = nil
        lastRefresh = refreshDate
    }

    func copyDiagnostics() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if let snapshot {
            let lastRefreshLine = "Last refresh: \(lastRefresh.map(BatteryFormatter.timestamp) ?? "Unavailable")"
            pasteboard.setString(snapshot.diagnosticText + "\n" + lastRefreshLine, forType: .string)
        } else {
            pasteboard.setString(errorMessage ?? "BatteryTruth: no battery snapshot", forType: .string)
        }
    }
}
