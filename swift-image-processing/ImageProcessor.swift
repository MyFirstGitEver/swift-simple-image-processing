//
//  ImageProcessor.swift
//  swift-image-processing
//
//  Created by Gia Duc on 13/07/2023.
//

import Foundation
import AppKit

enum Channel : Int{
    case RED = 0
    case GREEN = 1
    case BLUE = 2
}

struct Pair {
    var x : Int
    var y : Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    static func += (lhs : inout Pair, rhs : Pair) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}

struct RGB {
    var r : Double = 0
    var g : Double = 0
    var b: Double = 0
    
    init(_ randomise : Bool) {
        if randomise {
            r = Double.random(in: 0...255)
            g = Double.random(in: 0...255)
            b = Double.random(in: 0...255)
        }
    }
    
    init(_ color :NSColor) {
        r = color.redComponent * 255
        g = color.greenComponent * 255
        b = color.blueComponent * 255
    }
    
    func distFrom(target : RGB) -> Double {
        let rDiff = r - target.r
        let gDiff = g - target.g
        let bDiff = b - target.b
        
        return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
    }
    
    func toPixelArray() -> [Int] {
        var arr = Array.init(repeating: 255, count: 4)
        
        arr[0] = Int(r)
        arr[1] = Int(g)
        arr[2] = Int(b)
        
        return arr
    }
    
    mutating func reset () {
        r = 0
        g = 0
        b = 0
    }
    
    static func += (lhs : inout RGB, rhs : RGB) {
        lhs.r += rhs.r
        lhs.g += rhs.g
        lhs.b += rhs.b
    }
    
    static func /=(lhs : inout RGB, rhs : Double) {
        lhs.r /= rhs
        lhs.g /= rhs
        lhs.b /= rhs
    }
}

struct ImageProcessor {
    private var rep : NSBitmapImageRep?
    private static let ySobel = [
        [1, 2, 1],
        [0, 0, 0],
        [-1, -2, -1]
    ]
    
    private static let xSobel = [
        [1, 0, -1],
        [2, 0, -2],
        [1, 0, -1]
    ]
    
    init(rep : NSBitmapImageRep) {
        self.rep = rep
    }
    
    init(_ fileURL : URL) throws {
        let imgData = try Data(contentsOf: fileURL)
        let imgOrig = NSImage(data: imgData)

        let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                   pixelsWide: Int(imgOrig!.size.width),
                                   pixelsHigh: Int(imgOrig!.size.height),
                                   bitsPerSample: 8,
                                   samplesPerPixel: 4,
                                   hasAlpha: true,
                                   isPlanar: false,
                                   colorSpaceName: .deviceRGB,
                                   bytesPerRow: Int(imgOrig!.size.width) * 4,
                                   bitsPerPixel: 32)

        let ctx = NSGraphicsContext.init(bitmapImageRep: rep!)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep!)
        imgOrig!.draw(at: NSZeroPoint, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
        ctx?.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()
        
        self.rep = rep
    }
    
    func save(_ path : URL) throws {
        try rep?.representation(using: .png, properties: [:])?.write(to: path)
    }
    
    func eliminateChannels(_ channel : Channel) -> ImageProcessor? {
        if rep == nil {
            return nil
        }
        
        for x in 0..<rep!.pixelsWide {
            for y in 0..<rep!.pixelsHigh {
                var intensityVal : Double = 0
                let cell = rep?.colorAt(x: x, y: y)
                
                switch channel {
                case .RED:
                    intensityVal = Double(cell!.redComponent)
                    break
                case .GREEN:
                    intensityVal = Double(cell!.greenComponent)
                    break
                default:
                    intensityVal = Double(cell!.blueComponent)
                }
                
                var pixel = Array(repeating: 0, count: 4)
                pixel[channel.rawValue] = Int(intensityVal * 255)
                pixel[3] = 255
                
                rep?.setPixel(&pixel, atX: x, y: y)
            }
        }
        
        return self
    }
    
    func rotateLeft() -> ImageProcessor? {
        if rep == nil {
            return nil
        }
        
        let newRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: rep!.pixelsWide,
                                      pixelsHigh: rep!.pixelsHigh,
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: .deviceRGB,
                                      bytesPerRow: rep!.pixelsWide * 4,
                                      bitsPerPixel: 32)
        
        if newRep == nil {
            return nil
        }
        
        let w = rep!.pixelsWide
        let h = rep!.pixelsHigh
        
        for j in 0..<h {
            for i in 0..<w {
                var pixels = toPixeArray(rep!.colorAt(x: j, y: i)!)
                
                newRep!.setPixel(
                    &pixels,
                    atX: i,
                    y: h - 1 - j)
            }
        }
        
        return ImageProcessor(rep: newRep!)
    }
    
    func rotateRight() -> ImageProcessor? {
        if rep == nil {
            return nil
        }
        
        let newRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: rep!.pixelsWide,
                                      pixelsHigh: rep!.pixelsHigh,
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: .deviceRGB,
                                      bytesPerRow: rep!.pixelsWide * 4,
                                      bitsPerPixel: 32)
        
        if newRep == nil {
            return nil
        }
        
        let w = rep!.pixelsWide
        let h = rep!.pixelsHigh
        
        for j in 0..<h {
            for i in 0..<w {
                var pixels = toPixeArray(rep!.colorAt(x: j, y: i)!)
                
                newRep!.setPixel(
                    &pixels,
                    atX: w - 1 - i,
                    y: j)
            }
        }
        
        return ImageProcessor(rep: newRep!)
    }
    
    func draftThisImage() -> ImageProcessor? {
        if rep == nil {
            return nil
        }

        let newRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: rep!.pixelsWide - 2,
                                      pixelsHigh: rep!.pixelsHigh - 2,
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: .deviceRGB,
                                      bytesPerRow: rep!.pixelsWide * 4,
                                      bitsPerPixel: 32)
        
        for y in 0..<(rep!.pixelsHigh - 2) {
            for x in 0..<(rep!.pixelsWide - 2) {
                let xDiff = convolve3(
                    y: y,
                    x: x,
                    convolveOperator: ImageProcessor.xSobel)
                
                let yDiff = convolve3(
                    y: y,
                    x: x,
                    convolveOperator: ImageProcessor.ySobel)
                
                let gradientMagnitude = Int(sqrt(Double(xDiff * xDiff + yDiff * yDiff)))
                
                var pixel = Array(repeating: gradientMagnitude, count: 4)
                pixel[3] = 255
                
                newRep!.setPixel(&pixel, atX: x, y: y)
            }
        }
        
        return ImageProcessor(rep: newRep!)
    }
    
    func compressUsingKmeans(k : Int, effort : Int) -> ImageProcessor? {
        if rep == nil {
            return nil
        }
        
        var centroids : [RGB?] = Array(repeating: nil, count: k)
        
        var counter = Array(repeating: 0.0, count: k)
        var adapter = Array(repeating: RGB(false), count: k)
        
        for i in 0..<k {
            centroids[i] = RGB(true)
        }
        
        for _ in 0..<effort {
            for i in 0..<rep!.pixelsWide {
                for j in 0..<rep!.pixelsHigh {
                    let pixel = RGB(rep!.colorAt(x: i, y: j)!)
                    
                    let index = nearestIndex(
                        pixel: pixel,
                        centroids: &centroids)
                    
                    counter[index] += 1
                    adapter[index] += pixel
                }
            }
            
            for i in 0..<k {
                if counter[i] != 0 {
                    adapter[i] /= counter[i]
                }
                
                centroids[i] = adapter[i]
                
                adapter[i].reset()
                counter[i] = 0
            }
        }
        
        for i in 0..<rep!.pixelsWide {
            for j in 0..<rep!.pixelsHigh {
                let pixel = RGB(rep!.colorAt(x: i, y: j)!)
                
                let index = nearestIndex(
                    pixel: pixel,
                    centroids: &centroids)
                
                var arr = centroids[index]!.toPixelArray()
                rep!.setPixel(&arr, atX: i, y: j)
            }
        }
        
        return ImageProcessor(rep: rep!)
    }
    
    internal func nearestIndex(pixel : RGB, centroids : inout [RGB?]) -> Int {
        var minDist = Double.infinity
        var index = -1
        
        for (i, centroid) in centroids.enumerated() {
            if minDist > centroid!.distFrom(target: pixel) {
                minDist = centroid!.distFrom(target: pixel)
                index = i
            }
        }
        
        return index
    }
    
    internal func convolve3(y : Int, x : Int, convolveOperator : [[Int]]) -> Int {
        // O(1)
        var total : Int = 0

        for i in y...(y + 2) {
            for j in x...(x + 2) {
                let intensity = Int(rep!.colorAt(x: j, y: i)!.redComponent * 255)
                total += intensity * Int(convolveOperator[j - x][i - y])
            }
        }
        
        return total
    }
    
    internal func toPixeArray(_ color : NSColor) -> [Int] {
        var array = Array(repeating: 255, count: 4)
        
        array[0] = Int(color.redComponent * 255)
        array[1] = Int(color.greenComponent * 255)
        array[2] = Int(color.blueComponent * 255)
        
        return array
    }
}
