import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let output = root.appendingPathComponent("Assets/AppIcon/BatteryTruthAppIcon.png")

let size = NSSize(width: 1024, height: 1024)
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size.width),
    pixelsHigh: Int(size.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Failed to create bitmap context\n", stderr)
    exit(1)
}
bitmap.size = size

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

let canvas = NSRect(origin: .zero, size: size)
let cornerRadius: CGFloat = 228
let backgroundPath = NSBezierPath(roundedRect: canvas.insetBy(dx: 28, dy: 28), xRadius: cornerRadius, yRadius: cornerRadius)

NSColor.clear.setFill()
canvas.fill()

backgroundPath.addClip()

NSGradient(colors: [
    NSColor(calibratedRed: 0.012, green: 0.022, blue: 0.032, alpha: 1.0),
    NSColor(calibratedRed: 0.030, green: 0.170, blue: 0.135, alpha: 1.0),
    NSColor(calibratedRed: 0.060, green: 0.125, blue: 0.190, alpha: 1.0)
])?.draw(in: canvas, angle: -42)

NSColor(calibratedWhite: 1.0, alpha: 0.09).setFill()
NSBezierPath(roundedRect: canvas.insetBy(dx: 82, dy: 82), xRadius: 170, yRadius: 170).fill()

NSColor(calibratedRed: 0.19, green: 0.94, blue: 0.64, alpha: 0.34).setFill()
NSBezierPath(ovalIn: NSRect(x: -60, y: 650, width: 430, height: 430)).fill()

NSColor(calibratedRed: 0.32, green: 0.77, blue: 1.0, alpha: 0.28).setFill()
NSBezierPath(ovalIn: NSRect(x: 600, y: -40, width: 440, height: 440)).fill()

NSGraphicsContext.current?.cgContext.setShadow(
    offset: CGSize(width: 0, height: -18),
    blur: 46,
    color: NSColor.black.withAlphaComponent(0.36).cgColor
)

let batteryBody = NSRect(x: 146, y: 348, width: 650, height: 312)
let bodyPath = NSBezierPath(roundedRect: batteryBody, xRadius: 72, yRadius: 72)
NSColor(calibratedWhite: 0.0, alpha: 0.22).setFill()
bodyPath.fill()
NSColor(calibratedWhite: 1.0, alpha: 0.88).setStroke()
bodyPath.lineWidth = 34
bodyPath.stroke()

let fillRect = NSRect(x: 206, y: 410, width: 446, height: 188)
let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 42, yRadius: 42)
NSGraphicsContext.saveGraphicsState()
fillPath.addClip()
NSGradient(colors: [
    NSColor(calibratedRed: 0.42, green: 0.98, blue: 0.70, alpha: 0.96),
    NSColor(calibratedRed: 0.42, green: 0.82, blue: 1.00, alpha: 0.96)
])?.draw(in: fillRect, angle: 0)
NSGraphicsContext.restoreGraphicsState()

let capRect = NSRect(x: 812, y: 438, width: 74, height: 132)
let capPath = NSBezierPath(roundedRect: capRect, xRadius: 35, yRadius: 35)
NSColor(calibratedWhite: 1.0, alpha: 0.88).setFill()
capPath.fill()

let bolt = NSBezierPath()
bolt.move(to: NSPoint(x: 548, y: 754))
bolt.line(to: NSPoint(x: 358, y: 506))
bolt.line(to: NSPoint(x: 500, y: 506))
bolt.line(to: NSPoint(x: 458, y: 274))
bolt.line(to: NSPoint(x: 662, y: 550))
bolt.line(to: NSPoint(x: 524, y: 550))
bolt.close()

if let context = NSGraphicsContext.current?.cgContext {
    context.saveGState()
    context.setShadow(
        offset: CGSize(width: 0, height: -10),
        blur: 22,
        color: NSColor.black.withAlphaComponent(0.34).cgColor
    )
    bolt.addClip()
    NSGradient(colors: [
        NSColor(calibratedWhite: 1.0, alpha: 1.0),
        NSColor(calibratedRed: 0.72, green: 1.0, blue: 0.84, alpha: 1.0),
        NSColor(calibratedRed: 0.47, green: 0.88, blue: 1.0, alpha: 1.0)
    ])?.draw(in: NSRect(x: 350, y: 270, width: 320, height: 490), angle: 35)
    context.restoreGState()
}

NSGraphicsContext.restoreGraphicsState()

guard
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fputs("Failed to encode app icon PNG\n", stderr)
    exit(1)
}

try png.write(to: output, options: .atomic)
print(output.path)
