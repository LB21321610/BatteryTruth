# BatteryTruth 🔋✨

[English](README.md) | [中文](README.zh-CN.md)

**BatteryTruth shows what your Mac battery is really reporting.**

macOS gives you a clean battery percentage. BatteryTruth digs one layer deeper and reads the raw numbers from the Mac battery controller: real charge, real full-charge capacity, real design capacity, real health, and live power flow. No guessing tables. No rounded dashboard magic. Just the numbers your Mac is exposing. ⚡️

Download the latest build:
[BatteryTruth-macOS.zip](https://github.com/Leonleoi/BatteryTruth/releases/latest/download/BatteryTruth-macOS.zip)

## Why This Exists 🧠

Your menu bar might say `95%`, but the battery controller may be reporting more precise capacity data behind the scenes. BatteryTruth turns those raw values into a desktop dashboard so you can see:

- 🟢 true battery charge with two decimal places
- 💚 true battery health with two decimal places
- ⚡️ charging power and discharging power
- 🌡️ battery temperature and virtual temperature
- 🔁 cycle count and design cycle count
- 🔌 adapter details, voltage, and current
- 🧮 exactly which formula produced each result

## Features 🚀

- 🔋 **Real charge**: `AppleRawCurrentCapacity / AppleRawMaxCapacity`
- 💚 **Real health**: `AppleRawMaxCapacity / DesignCapacity`
- 🧩 **No hardcoded model table**: `DesignCapacity` is read from the current Mac
- ⚡️ **Live power flow**: charging watts and discharging watts from real voltage/current fields
- 🌡️ **Thermal readings**: battery temperature and virtual temperature when available
- 🖥️ **Mac-aware behavior**: MacBooks show internal battery data; desktop Macs show a clear no-battery state
- 🪟 **Native SwiftUI app**: glass-style dashboard, full-window layout, smooth scrolling, and menu bar display
- 🎛️ **Built-in settings**: menu bar style, charge-limit monitoring, and thermal-limit monitoring
- 🎨 **App icon included**: based on MIT-licensed Bootstrap Icons `battery-charging`

## Battery Math 🧮

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

Health is **not capped at 100%**. A new or recently calibrated battery can report a full-charge capacity above design capacity, and BatteryTruth shows that real value. ✅

## What It Does Not Do 🚧

BatteryTruth does **not** fake charging control. On macOS 15, there is no public API for this app to directly cut charging.

The charge-limit and thermal-protection settings are monitoring and warning features based on real battery data. They are useful signals, not hidden system-level charging switches. 🛡️

## Screenshot / UI Mood 🌌

BatteryTruth is designed as a dark glass desktop dashboard: large live numbers, a visual battery icon, health ring, raw capacity panel, power panel, and settings right inside the main UI.

## Requirements 🧰

- macOS 15 or newer
- Xcode Command Line Tools
- Swift 6 toolchain

## Build From Source 🛠️

```bash
swift test
./script/build_and_run.sh --verify
```

The app bundle is created at:

```text
dist/BatteryTruth.app
```

## Package a Release Zip 📦

```bash
./script/package_release.sh
```

The release zip is created at:

```text
dist/BatteryTruth-macOS.zip
```

## Disclaimer ⚠️

Use BatteryTruth at your own risk. This app reads and displays battery information from macOS and IOKit, but it is provided **as-is**, without warranty.

The author is not responsible for unexpected behavior, incorrect readings, data loss, device issues, battery issues, system instability, financial loss, or any other direct or indirect damage that may occur while installing, running, building, modifying, or relying on this app.

BatteryTruth is an informational tool only. It is not official Apple software, not a repair tool, and not a guarantee of battery condition or device safety. Always verify critical battery or hardware decisions with Apple diagnostics, macOS System Settings, or qualified service providers.

中文声明：本软件按现状提供，使用风险由使用者自行承担。安装、运行、构建、修改或依赖本软件过程中如出现意外、读数不准、数据丢失、设备问题、电池问题、系统异常、经济损失或其他直接/间接损失，作者不承担责任。本软件仅用于信息展示，不是 Apple 官方工具，也不保证电池状态或设备安全。

## Icon License 🎨

The battery charging icon source is based on Bootstrap Icons `battery-charging`, licensed under MIT.

See:

- `Assets/AppIcon/bootstrap-battery-charging.svg`
- `Assets/AppIcon/BOOTSTRAP_ICONS_LICENSE.md`
- https://icons.getbootstrap.com/icons/battery-charging/
- https://github.com/twbs/icons

## Project License 📄

BatteryTruth is released under the MIT License. See `LICENSE`.
