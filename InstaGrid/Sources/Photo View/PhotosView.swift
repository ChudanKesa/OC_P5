//
//  PhotosView.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 02/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

class PhotosView: UIView {

    // MARK: - Properties
    
    lazy var rightButtonStyle = ButtonStyle()
    lazy var leftButtonStyle = ButtonStyle()
    lazy var rectangleStyle = ButtonStyle()
    lazy var topRightButtonStyle = ButtonStyle()
    lazy var topLeftButtonStyle = ButtonStyle()
    
    lazy var invisibleStyle: ButtonStyle = {
        var style = ButtonStyle()
        style.color = UIColor(white: 1, alpha: 0)
        style.text = ""
        style.textColor = UIColor(white: 1, alpha: 0)
        guard let font = UIFont(name: "System", size: 0) else { return style }
        style.font = font
        return style
    }()
    
    enum layout {
        case first, second, third
    }
    
    lazy var currentStyle = layout.first
    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var rectangle: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topLeftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var topRightButton: UIButton!

    @IBOutlet weak var rectangleView: UIImageView!
    @IBOutlet weak var leftButtonView: UIImageView!
    @IBOutlet weak var topLeftButtonView: UIImageView!
    @IBOutlet weak var rightButtonView: UIImageView!
    @IBOutlet weak var topRightButtonView: UIImageView!
    
    
    @IBAction func rectangleButtonTouched(_ sender: UIButton) {
        sendNotification("rectangle")
    }
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        sendNotification("leftButton")
    }
    @IBAction func topLeftButtonTouched(_ sender: UIButton) {
        sendNotification("topLeftButton")
    }
    @IBAction func rightButtonTouched(_ sender: UIButton) {
        sendNotification("rightButton")
    }
    @IBAction func topRightButtonTouched(_ sender: UIButton) {
        sendNotification("topRightButton")
    }
    
    // MARK: - Notification
    
    private func sendNotification(_ name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    // MARK: - Configuation
    
    func reccordStyles() {
        let buttons = [rectangle, leftButton, rightButton, topLeftButton, topRightButton]
        let styles = [rectangleStyle, leftButtonStyle, rightButtonStyle, topLeftButtonStyle, topRightButtonStyle]
        for index in buttons.indices {
            styles[index].color = buttons[index]!.backgroundColor!
            styles[index].font = buttons[index]!.titleLabel!.font
            styles[index].text = buttons[index]!.currentTitle!
            styles[index].textColor = buttons[index]!.titleLabel!.textColor
        }
    }
    
    func setButtonStyle(button: UIButton, style: ButtonStyle) {
        button.backgroundColor = style.color
        button.titleLabel!.font = style.font
        button.titleLabel!.text = style.text
        button.titleLabel!.textColor = style.textColor
    }
    
}
