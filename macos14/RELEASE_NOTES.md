# BatteryTruth v1.0.1 for macOS 14

macOS 14 compatibility release.

## Highlights

- Reads real Mac battery charge from `AppleRawCurrentCapacity / AppleRawMaxCapacity`.
- Reads real battery health from `AppleRawMaxCapacity / DesignCapacity`.
- Displays charging and discharging power from battery-controller voltage and current.
- Shows battery temperature, virtual temperature, cycle count, adapter data, raw capacity data, and calculation source.
- Uses the current Mac battery controller's `DesignCapacity`; it does not use a fixed model-capacity table.
- Includes a full-window SwiftUI glass dashboard, menu bar display, and in-app settings.
- Includes a macOS `.app` bundle in the release asset.

## Requirements

- macOS 14 or newer
- Apple laptop with an internal battery for full raw readings

## Notes

BatteryTruth does not directly control charging. Charge-limit and thermal-protection settings are monitoring features based on real battery data.

The app bundle is unsigned and not notarized. If macOS Gatekeeper blocks launch, build locally from source with:

```bash
./script/build_and_run.sh --verify
```

## Disclaimer

Use BatteryTruth at your own risk. The app is provided as-is without warranty. The author is not responsible for unexpected behavior, incorrect readings, data loss, device issues, battery issues, system instability, financial loss, or other direct or indirect damage caused by installing, running, building, modifying, or relying on this app.

中文声明：本软件按现状提供，使用风险由使用者自行承担。安装、运行、构建、修改或依赖本软件过程中如出现意外、读数不准、数据丢失、设备问题、电池问题、系统异常、经济损失或其他直接/间接损失，作者不承担责任。
