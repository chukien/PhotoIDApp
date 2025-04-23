//
//  ExtensionFile.swift
//  PhotoIDApp
//
//  Created by QRVN on 22/4/25.
//
import UIKit

extension UIImage {
    //Kiểm tra và xoay ảnh nếu bị xoay sai chiều
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
    
    //Cắt ảnh về tỉ lệ dọc (portrait):
    func cropToPortrait(aspectRatio: CGFloat = 3.0/4.0) -> UIImage? {
        let originalWidth = size.width
        let originalHeight = size.height
        let targetRatio = aspectRatio
        
        var cropRect: CGRect
        
        if originalWidth / originalHeight > targetRatio {
            // Quá ngang -> cắt chiều ngang
            let newWidth = originalHeight * targetRatio
            let x = (originalWidth - newWidth) / 2
            cropRect = CGRect(x: x, y: 0, width: newWidth, height: originalHeight)
        } else {
            // Quá cao -> cắt chiều dọc
            let newHeight = originalWidth / targetRatio
            let y = (originalHeight - newHeight) / 2
            cropRect = CGRect(x: 0, y: y, width: originalWidth, height: newHeight)
        }
        
        guard let cgImage = cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    //Xử lí ảnh bị mirror(gương) nếu chụp camera trước:
    func flipHorizontally() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
}
