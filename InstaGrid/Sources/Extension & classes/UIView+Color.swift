//
//  UIView+Color.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 12/06/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

extension UIView {
    func colorBackgroundGreen() {
        if let rightView = self as? PhotosView {
            guard let safeView = rightView.mainView else { return }
            safeView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
    }
    
    func colorBackgroundBlue() {
        if let rightView = self as? PhotosView {
            guard let safeView = rightView.mainView else { return }
            safeView.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
        }
    }
}

