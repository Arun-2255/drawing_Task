//
//  Common.swift
//  SketchDraw
//
//  Created by Arun  on 12/09/24.
//

import Foundation
import UIKit
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size)
                        .applying(CGAffineTransform(rotationAngle: radians))
                        .integral.size
        newSize = CGSize(width: floor(newSize.width), height: floor(newSize.height))

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: radians)

        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
}
