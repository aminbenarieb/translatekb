#!/usr/bin/env swift
// Renders the 1024×1024 App Store icon. Two-bubble translation metaphor —
// Latin "A" and Cyrillic "Я" overlapping speech bubbles on a brand gradient.
// CoreGraphics + CoreText only — no third-party dependencies. Output is a
// flat (no alpha) PNG that Apple accepts.
//
// Usage: swift Distribution/scripts/generate-icon.swift <output.png>

import Foundation
import CoreGraphics
import ImageIO
import CoreText
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: generate-icon.swift <output.png>\n".utf8))
    exit(2)
}
let outPath = CommandLine.arguments[1]
let size: CGFloat = 1024

let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: Int(size),
    height: Int(size),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: cs,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    FileHandle.standardError.write(Data("failed to create context\n".utf8))
    exit(1)
}

// ─── Background gradient ──────────────────────────────────────────────────
let bgColors = [
    CGColor(red: 0.17, green: 0.40, blue: 0.95, alpha: 1), // electric blue
    CGColor(red: 0.40, green: 0.25, blue: 0.93, alpha: 1)  // violet
] as CFArray
let bgGradient = CGGradient(colorsSpace: cs, colors: bgColors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(
    bgGradient,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: size, y: 0),
    options: []
)

// ─── Helper: draw a speech-bubble rounded rect with a tail ────────────────
func bubblePath(rect: CGRect, corner: CGFloat, tailFrom: CGPoint, tailTip: CGPoint, tailTo: CGPoint) -> CGPath {
    let path = CGMutablePath()
    path.addRoundedRect(in: rect, cornerWidth: corner, cornerHeight: corner)
    path.move(to: tailFrom)
    path.addLine(to: tailTip)
    path.addLine(to: tailTo)
    path.closeSubpath()
    return path
}

// ─── Helper: centered text in a rect ──────────────────────────────────────
func drawCentered(letter: String, in rect: CGRect, color: CGColor, fontSize: CGFloat) {
    let font = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, fontSize, nil)
    let attrs: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: color
    ]
    let attr = CFAttributedStringCreate(nil, letter as CFString, attrs as CFDictionary)!
    let line = CTLineCreateWithAttributedString(attr)
    let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
    ctx.textPosition = CGPoint(
        x: rect.midX - bounds.width / 2 - bounds.origin.x,
        y: rect.midY - bounds.height / 2 - bounds.origin.y
    )
    CTLineDraw(line, ctx)
}

// ─── Back bubble (Latin "A") ──────────────────────────────────────────────
let backRect = CGRect(x: 120, y: 380, width: 520, height: 460)
let backPath = bubblePath(
    rect: backRect,
    corner: 110,
    tailFrom: CGPoint(x: 230, y: 400),
    tailTip:  CGPoint(x: 160, y: 290),
    tailTo:   CGPoint(x: 320, y: 400)
)

ctx.saveGState()
// soft shadow under back bubble
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.20))
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.94))
ctx.addPath(backPath)
ctx.fillPath()
ctx.restoreGState()

drawCentered(
    letter: "A",
    in: backRect,
    color: CGColor(red: 0.17, green: 0.40, blue: 0.95, alpha: 1),
    fontSize: 360
)

// ─── Front bubble (Cyrillic "Я") ──────────────────────────────────────────
let frontRect = CGRect(x: 380, y: 180, width: 520, height: 460)
let frontPath = bubblePath(
    rect: frontRect,
    corner: 110,
    tailFrom: CGPoint(x: 800, y: 200),
    tailTip:  CGPoint(x: 880, y: 100),
    tailTo:   CGPoint(x: 720, y: 200)
)

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 40, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.28))
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
ctx.addPath(frontPath)
ctx.fillPath()
ctx.restoreGState()

drawCentered(
    letter: "Я",
    in: frontRect,
    color: CGColor(red: 0.40, green: 0.25, blue: 0.93, alpha: 1),
    fontSize: 360
)

// ─── Export ───────────────────────────────────────────────────────────────
guard let image = ctx.makeImage() else {
    FileHandle.standardError.write(Data("failed to make image\n".utf8))
    exit(1)
}
let url = URL(fileURLWithPath: outPath)
guard let dst = CGImageDestinationCreateWithURL(
    url as CFURL,
    UTType.png.identifier as CFString,
    1, nil
) else {
    FileHandle.standardError.write(Data("failed to create destination\n".utf8))
    exit(1)
}
CGImageDestinationAddImage(dst, image, nil)
guard CGImageDestinationFinalize(dst) else {
    FileHandle.standardError.write(Data("failed to finalize destination\n".utf8))
    exit(1)
}
print("wrote \(outPath)")
