//
//  UIView+UIImage.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 04/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

extension UIView {
    func toUIImage() -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return image
    }
}
