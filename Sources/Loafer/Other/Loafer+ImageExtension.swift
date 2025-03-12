
import UIKit
import Accelerate

extension UIImage {
    
    public func blurred(withRadius radius: CGFloat) -> UIImage {
        
        guard let cgImage = cgImage else {
            assertionFailure("[Loafer] Blur only works for CG-based image.")
            return self
        }
        
        let s = max(radius, 2.0)
        let pi2 = 2 * CGFloat.pi
        let sqrtPi2 = sqrt(pi2)
        var targetRadius = floor(s * 3.0 * sqrtPi2 / 4.0 + 0.5)
        
        if targetRadius.isEven { targetRadius += 1 }
        
        let iterations: Int
        if radius < 0.5 {
            iterations = 1
        } else if radius < 1.5 {
            iterations = 2
        } else {
            iterations = 3
        }
        
        let w = Int(size.width)
        let h = Int(size.height)
        
        func createEffectBuffer(_ context: CGContext) -> vImage_Buffer {
            let data = context.data
            let width = vImagePixelCount(context.width)
            let height = vImagePixelCount(context.height)
            let rowBytes = context.bytesPerRow
            
            return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
        }
        GraphicsContext.begin(size: size, scale: scale)
        guard let context = GraphicsContext.current(size: size, scale: scale, inverting: true, cgImage: cgImage) else {
            assertionFailure("[Loafer] Failed to create CG context for blurring image.")
            return self
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        GraphicsContext.end()
        
        var inBuffer = createEffectBuffer(context)
        
        GraphicsContext.begin(size: size, scale: scale)
        guard let outContext = GraphicsContext.current(size: size, scale: scale, inverting: true, cgImage: cgImage) else {
            assertionFailure("[Loafer] Failed to create CG context for blurring image.")
            return self
        }
        defer { GraphicsContext.end() }
        var outBuffer = createEffectBuffer(outContext)
        
        for _ in 0 ..< iterations {
            let flag = vImage_Flags(kvImageEdgeExtend)
            vImageBoxConvolve_ARGB8888(
                &inBuffer, &outBuffer, nil, 0, 0, UInt32(targetRadius), UInt32(targetRadius), nil, flag)
            (inBuffer, outBuffer) = (outBuffer, inBuffer)
        }
        
        #if os(macOS)
        let result = outContext.makeImage().flatMap {
            fixedForRetinaPixel(cgImage: $0, to: size)
        }
        #else
        let result = outContext.makeImage().flatMap {
            UIImage(cgImage: $0, scale: self.scale, orientation: self.imageOrientation)
        }
        #endif
        guard let blurredImage = result else {
            assertionFailure("[Loafer] Can not make an blurred image within this context.")
            return self
        }
        
        return blurredImage
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func scale(by scale: CGFloat) -> UIImage? {
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resize(targetSize: scaledSize)
    }
    
    func compressImageSize() -> UIImage? {
        guard var zipImageData = self.jpegData(compressionQuality: 1.0) else { return self }
        let originalImgSize = zipImageData.count/1024 as Int
        
        if originalImgSize > 1500 {
            zipImageData = self.jpegData(compressionQuality: 0.2) ?? Data()
        }else if originalImgSize > 600 {
            zipImageData = self.jpegData(compressionQuality: 0.4) ?? Data()
        }else if originalImgSize > 400 {
            zipImageData = self.jpegData(compressionQuality: 0.6) ?? Data()
        }else if originalImgSize > 300 {
            zipImageData = self.jpegData(compressionQuality: 0.7) ?? Data()
        }else if originalImgSize > 200 {
            zipImageData = self.jpegData(compressionQuality: 0.8) ?? Data()
        }
        
        return UIImage(data: zipImageData)
    }
    
}

fileprivate enum GraphicsContext {
    static func begin(size: CGSize, scale: CGFloat) {
        #if os(macOS)
        NSGraphicsContext.saveGraphicsState()
        #else
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        #endif
    }
    
    static func current(size: CGSize, scale: CGFloat, inverting: Bool, cgImage: CGImage?) -> CGContext? {
        #if os(macOS)
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: cgImage?.bitsPerComponent ?? 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0) else
        {
            assertionFailure("[Loafer] Image representation cannot be created.")
            return nil
        }
        rep.size = size
        guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
            assertionFailure("[Loafer] Image context cannot be created.")
            return nil
        }
        
        NSGraphicsContext.current = context
        return context.cgContext
        #else
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        if inverting { // If drawing a CGImage, we need to make context flipped.
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0, y: -size.height)
        }
        return context
        #endif
    }
    
    static func end() {
        #if os(macOS)
        NSGraphicsContext.restoreGraphicsState()
        #else
        UIGraphicsEndImageContext()
        #endif
    }
}

fileprivate extension CGFloat {
    var isEven: Bool {
        return truncatingRemainder(dividingBy: 2.0) == 0
    }
}
