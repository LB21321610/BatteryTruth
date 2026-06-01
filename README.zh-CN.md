# BatteryTruth 🔋✨

[English](README.md) | [中文](README.zh-CN.md)

**BatteryTruth 用来查看你的 Mac 电池到底在上报什么真实数据。**

macOS 会给你一个干净好看的电量百分比。BatteryTruth 往下多看一层，直接读取 Mac 电池控制器暴露出来的 raw 数据：真实电量、满充容量、设计容量、真实健康度和实时功率流向。不靠机型容量表猜，不拿系统圆整后的数字糊弄你。你的 Mac 报什么，它就尽量展示什么。⚡️

下载最新版：
[BatteryTruth-macOS.zip](https://github.com/Leonleoi/BatteryTruth/releases/latest/download/BatteryTruth-macOS.zip)

## 为什么做这个 🧠

菜单栏可能只告诉你 `95%`，但电池控制器背后其实可能有更精确的容量数据。BatteryTruth 把这些 raw 字段整理成一个桌面仪表盘，让你能看到：

- 🟢 小数点后两位的真实电量
- 💚 小数点后两位的真实电池健康度
- ⚡️ 实时充电功率和掉电功率
- 🌡️ 电池温度和虚拟温度
- 🔁 循环次数和设计循环次数
- 🔌 适配器、电压、电流等原始数据
- 🧮 每个核心读数到底是怎么算出来的

## 功能 🚀

- 🔋 **真实电量**：`AppleRawCurrentCapacity / AppleRawMaxCapacity`
- 💚 **真实健康度**：`AppleRawMaxCapacity / DesignCapacity`
- 🧩 **不写死机型容量表**：`DesignCapacity` 从当前 Mac 的电池控制器读取
- ⚡️ **实时功率流向**：根据真实电压/电流字段计算充电功率和掉电功率
- 🌡️ **温度读数**：可用时显示电池温度和虚拟温度
- 🖥️ **适配不同 Mac**：MacBook 显示内置电池数据；台式 Mac 或无内置电池设备显示明确状态
- 🪟 **原生 SwiftUI 应用**：深色玻璃仪表盘、全窗口布局、顺滑滚动、菜单栏显示
- 🎛️ **内置设置面板**：菜单栏样式、充电上限监测、热保护阈值都能直接调
- 🎨 **应用图标已包含**：基于 MIT 许可的 Bootstrap Icons `battery-charging`

## 电池计算方式 🧮

raw 电池字段可用时，BatteryTruth 不使用系统 UI 圆整后的百分比。

真实电量：

```text
AppleRawCurrentCapacity / AppleRawMaxCapacity * 100
```

真实健康度：

```text
AppleRawMaxCapacity / DesignCapacity * 100
```

实时功率：

```text
Voltage(mV) * InstantAmperage(mA) / 1,000,000
```

健康度**不会强制截断到 100%**。新电池或刚校准过的电池，满充容量可能高于设计容量，BatteryTruth 会按真实值显示。✅

## 它不会做什么 🚧

BatteryTruth **不会伪造充电控制**。在 macOS 15 上，本 App 没有可直接调用的公开接口来切断充电。

App 内的充电上限和热保护功能，是基于真实电池数据的监测和提示功能。它们是有用的信号，不是隐藏的系统级断充开关。🛡️

## 界面感觉 🌌

BatteryTruth 的界面是深色玻璃桌面仪表盘：大号实时数字、可视化电池图标、健康度环、原始容量面板、功率面板，以及直接放在主界面里的设置选项。

## 系统要求 🧰

- macOS 15 或更新版本
- Xcode Command Line Tools
- Swift 6 工具链

## 从源码构建 🛠️

```bash
swift test
./script/build_and_run.sh --verify
```

App bundle 会生成到：

```text
dist/BatteryTruth.app
```

## 打包 Release Zip 📦

```bash
./script/package_release.sh
```

Release zip 会生成到：

```text
dist/BatteryTruth-macOS.zip
```

## 免责声明 ⚠️

本软件按现状提供，使用风险由使用者自行承担。

安装、运行、构建、修改或依赖本软件过程中如出现意外、读数不准、数据丢失、设备问题、电池问题、系统异常、经济损失或其他直接/间接损失，作者不承担责任。

BatteryTruth 仅用于信息展示，不是 Apple 官方软件，不是维修工具，也不保证电池状态或设备安全。涉及关键电池或硬件判断时，请以 Apple 诊断、macOS 系统设置或合格维修服务商的结论为准。

English disclaimer: Use BatteryTruth at your own risk. This app is provided as-is without warranty. The author is not responsible for unexpected behavior, incorrect readings, data loss, device issues, battery issues, system instability, financial loss, or other direct or indirect damage caused by installing, running, building, modifying, or relying on this app.

## 图标许可 🎨

电池充电图标来源基于 Bootstrap Icons `battery-charging`，使用 MIT 许可证。

见：

- `Assets/AppIcon/bootstrap-battery-charging.svg`
- `Assets/AppIcon/BOOTSTRAP_ICONS_LICENSE.md`
- https://icons.getbootstrap.com/icons/battery-charging/
- https://github.com/twbs/icons

## 项目许可证 📄

BatteryTruth 使用 MIT License。见 `LICENSE`。
