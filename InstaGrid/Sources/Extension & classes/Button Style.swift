//
//  Button Style.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 04/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import Foundation
import UIKit

class ButtonStyle {
    var color: UIColor
    var font: UIFont
    var text: String
    var textColor: UIColor
    
    init(color: UIColor, font: UIFont, text: String, textColor: UIColor) {
        self.color = color
        self.font = font
        self.text = text
        self.textColor = textColor
    }
    
    convenience init() {
        self.init(color: UIColor(), font: UIFont(), text: "", textColor: UIColor())
    }
}
