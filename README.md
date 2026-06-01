# BatteryTruth

BatteryTruth is a native macOS SwiftUI app for reading real battery capacity, real battery health, and live power data from the Mac battery controller.

It is built for macOS 15+ and packaged with Swift Package Manager.

## Features

- Real battery charge percentage with two decimal places
- Real battery health percentage with two decimal places
- No hardcoded design-capacity table: `DesignCapacity` is read from the current Mac
- Live charging power and discharging power
- Voltage, current, battery temperature, virtual temperature, cycle count, design cycle count, and adapter data
- AppleSmartBattery raw data first, IOPowerSources fallback when raw fields are unavailable
- Works across Mac models that expose an internal battery; desktop Macs show an explicit no-battery state
- SwiftUI desktop dashboard with dark glass styling, full-window layout, smooth scrolling, and menu bar display
- Built-in settings panel for menu bar style, charge-limit monitoring, and thermal-limit monitoring
- MIT-licensed app icon source based on Bootstrap Icons `battery-charging`

## Battery Math

BatteryTruth avoids rounded system UI values when raw battery fields are available.

True charge:

```text
AppleRawCurrentCapacity / AppleRawMaxCapacity * 100
```

True health:

```text
AppleRawMaxCapacity / DesignCapacity * 100
```

Power:

```text
Voltage(mV) * InstantAmperage(mA) / 1,000,000
```

Health is not capped at 100%. New or recently calibrated batteries can report a full-charge capacity above design capacity.

## Limits

BatteryTruth does not fake charging control. On macOS 15 there is no public API for this app to directly cut charging. Charge-limit and thermal-protection settings in the app are monitoring and warning features based on real battery data.

## Disclaimer

Use BatteryTruth at your own risk. This app reads and displays battery information from macOS and IOKit, but it is provided as-is without warranty.

The author is not responsible for any unexpected behavior, incorrect readings, data loss, device issues, battery issues, system instability, financial loss, or other direct or indirect damage that may occur while installing, running, building, modifying, or relying on this app.

BatteryTruth is an informational tool only. It is not official Apple software, not a repair tool, and not a guarantee of battery condition or device safety. Always verify critical battery or hardware decisions with Apple diagnostics, macOS System Settings, or qualified service providers.

中文声明：本软件按现状提供，使用风险由使用者自行承担。安装、运行、构建、修改或依赖本软件过程中如出现意外、读数不准、数据丢失、设备问题、电池问题、系统异常、经济损失或其他直接/间接损失，作者不承担责任。本软件仅用于信息展示，不是 Apple 官方工具，也不保证电池状态或设备安全。

## Requirements

- macOS 15 or newer
- Xcode command line tools
- Swift 6 toolchain

## Build

```bash
swift test
./script/build_and_run.sh --verify
```

The app bundle is created at:

```text
dist/BatteryTruth.app
```

## Package Release Asset

```bash
./script/package_release.sh
```

The release zip is created at:

```text
dist/BatteryTruth-macOS.zip
```

## Icon License

The battery charging icon source is based on Bootstrap Icons `battery-charging`, licensed under MIT.

See:

- `Assets/AppIcon/bootstrap-battery-charging.svg`
- `Assets/AppIcon/BOOTSTRAP_ICONS_LICENSE.md`
- https://icons.getbootstrap.com/icons/battery-charging/
- https://github.com/twbs/icons

## Project License

BatteryTruth is released under the MIT License. See `LICENSE`.
