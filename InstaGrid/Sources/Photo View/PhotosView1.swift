
//
//  PhotosView.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 02/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

class PhotosView: UIView {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PhotosView1", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        for view in views {
            guard let safeView = view else { return }
            safeView.alpha = 0
            safeView.layer.zPosition = -1
            safeView.isUserInteractionEnabled = false
        }
        viewsToFollowButtons()
        reccordStyles()        
    }
    
    


    // MARK: - Properties
    
    var upperYPosition = CGFloat()
    var downYPosition = CGFloat()
    
    var topRightViewXPosition = CGFloat()
    
    private lazy var valuesAreSet = false
    
    private var bufferTopRightViewXPosition: CGFloat?
    
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
    
    private lazy var views = [rectangleView, leftButtonView, rightButtonView, topLeftButtonView, topRightButtonView]
    private lazy var buttons = [rectangle, leftButton, rightButton, topLeftButton, topRightButton]
    
    // MARK: - Outlets & actions
    

    @IBOutlet var mainView: UIView!
    
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
    
    
    // Reccord original look of the buttons so they can be restored later if needed
    private func reccordStyles() {
        let styles = [rectangleStyle, leftButtonStyle, rightButtonStyle, topLeftButtonStyle, topRightButtonStyle]
        
        for index in buttons.indices {
            guard let safeButton = buttons[index] else { return }
            guard let title = safeButton.currentTitle else { return }
            guard let label = safeButton.titleLabel else { return }
            guard let backgroundColor = safeButton.backgroundColor else { return }
            styles[index].color = backgroundColor
            styles[index].font = label.font
            styles[index].text = title
            styles[index].textColor = label.textColor
        }
    }
    
    
    func setButtonStyle(button: UIButton, style: ButtonStyle) {
        button.backgroundColor = style.color
        guard let label = button.titleLabel else { return }
        label.font = style.font
        label.text = style.text
        label.textColor = style.textColor
    }
    
    
    private func viewsToFollowButtons() {
        for index in views.indices {
            guard let safeView = views[index] else { return }
            guard let safeButton = buttons[index] else { return }
            safeView.frame = safeButton.frame
        }
    }
    
    
    // Makes sure the views can't be seen if they don't hold an image, and get hidden along with their button if the layout changes.
    private func hideViewIfButtonIs() {
        for index in views.indices {
            guard let safeView = views[index] else { return }
            guard let safeButton = buttons[index] else { return }
            if safeView.image == nil {
                safeView.alpha = 0
            } else {
                safeView.alpha = safeButton.alpha
            }
        }
    }
    
    
    // Reccords the present position of the buttons.
    // To be used when app launches to get the values of the coordinates the layout is going to use.
    func setPositionValues(up: CGFloat, down: CGFloat, right: CGFloat) {
        if !valuesAreSet {
            upperYPosition = up
            downYPosition = down
            topRightViewXPosition = right
            valuesAreSet = true
        }
    }
    
    
    // Changes layout. The following functions are its parts, cut for clarity.
    func changeLayout(from firstLayout: PhotosView.layout, to secondLayout: PhotosView.layout, animated: Bool) {
        if animated {
            animateLayout(from: firstLayout, to: secondLayout)
        } else {
            switchLayout(from: firstLayout, to: secondLayout)
        }
    }
    
    private func animateLayout(from origin: PhotosView.layout, to newLayout: PhotosView.layout) {
        switch newLayout {
        case .first:
            animatedGrid1(from: origin)
        case .second:
            animatedGrid2(from: origin)
        case .third:
            animatedGrid3(from: origin)
        }
    }
    
    private func switchLayout(from origin: PhotosView.layout, to newLayout: PhotosView.layout) {
        switch newLayout {
        case .first:
            grid1(from: origin)
        case .second:
            grid1(from: origin)
        case .third:
            grid1(from: origin)
        }
    }
    
    private func animatedGrid1(from: PhotosView.layout) {
        switch from {
        case .first:
            break
        case .second:
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.rectangle.frame.origin.y = self.upperYPosition
                            self.leftButton.frame.origin.y = self.downYPosition
                            self.rightButton.frame.origin.y = self.downYPosition
                            
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        case .third:
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.topLeftButton.alpha = 0
                            self.topRightButton.alpha = 0
                            self.rectangle.frame.origin.y = self.upperYPosition
                            self.rectangle.alpha = 1
                            
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        }
    }
    
    private func animatedGrid2(from: PhotosView.layout) {
        switch from {
        case .first:
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.rectangle.frame.origin.y = self.downYPosition
                            self.leftButton.frame.origin.y = self.upperYPosition
                            self.rightButton.frame.origin.y = self.upperYPosition
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        case .second:
            break
        case .third:
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.rectangle.frame.origin.y = self.downYPosition
                            self.rectangle.alpha = 1
                            self.topRightButton.alpha = 0
                            self.topLeftButton.alpha = 0
                            self.leftButton.frame.origin.y = self.upperYPosition
                            self.rightButton.frame.origin.y = self.upperYPosition
                            
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        }
    }
    
    private func animatedGrid3(from: PhotosView.layout) {
        switch from {
        case .first:
            topLeftButton.alpha = 0
            topLeftButton.frame.origin.x -= 50
            topLeftButton.frame.origin.y -= 200
            topRightButton.alpha = 0
            topRightButton.frame.origin.x += 50
            topRightButton.frame.origin.y -= 200
            viewsToFollowButtons()
            hideViewIfButtonIs()
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.topLeftButton.alpha = 1
                            self.topLeftButton.frame.origin.x += 50
                            self.topLeftButton.frame.origin.y += 200
                            self.topRightButton.alpha = 1
                            self.topRightButton.frame.origin.x -= 50
                            self.topRightButton.frame.origin.y += 200
                            self.rectangle.frame.origin.y = self.downYPosition
                            self.rectangle.alpha = 0
                            
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        case .second:
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.rectangle.frame.origin.y = self.upperYPosition
                            self.rectangle.alpha = 0
                            self.leftButton.frame.origin.y = self.downYPosition
                            self.rightButton.frame.origin.y = self.downYPosition
                            self.topRightButton.alpha = 1
                            self.topLeftButton.alpha = 1
                            
                            self.viewsToFollowButtons()
                            self.hideViewIfButtonIs()
            },
                           completion: nil
            )
        case .third:
            break
        }
    }
    
    private func grid1(from: PhotosView.layout) {
        switch from {
        case .first:
            break
        case .second:
            self.rectangle.frame.origin.y = self.upperYPosition
            self.leftButton.frame.origin.y = self.downYPosition
            self.rightButton.frame.origin.y = self.downYPosition
            
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        case .third:
            self.topLeftButton.alpha = 0
            self.topRightButton.alpha = 0
            self.rectangle.frame.origin.y = self.upperYPosition
            self.rectangle.alpha = 1
            
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        }
    }
    
    private func grid2(from: PhotosView.layout) {
        switch from {
        case .first:
            self.rectangle.frame.origin.y = self.downYPosition
            self.leftButton.frame.origin.y = self.upperYPosition
            self.rightButton.frame.origin.y = self.upperYPosition
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        case .second:
            break
        case .third:
            self.rectangle.frame.origin.y = self.downYPosition
            self.rectangle.alpha = 1
            self.topRightButton.alpha = 0
            self.topLeftButton.alpha = 0
            self.leftButton.frame.origin.y = self.upperYPosition
            self.rightButton.frame.origin.y = self.upperYPosition
            
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        }
    }
    
    private func grid3(from: PhotosView.layout) {
        switch from {
        case .first:
            self.topLeftButton.alpha = 1
            self.topLeftButton.frame.origin.y = self.upperYPosition
            self.topRightButton.alpha = 1
            self.topRightButton.frame.origin.y = self.upperYPosition
            self.rectangle.frame.origin.y = self.downYPosition
            topRightButton.frame.origin.x = topRightViewXPosition
            self.rectangle.alpha = 0
            
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        case .second:
            self.rectangle.frame.origin.y = self.upperYPosition
            self.rectangle.alpha = 0
            self.leftButton.frame.origin.y = self.downYPosition
            self.rightButton.frame.origin.y = self.downYPosition
            self.topRightButton.alpha = 1
            self.topLeftButton.alpha = 1
            topRightButton.frame.origin.x = topRightViewXPosition
            
            self.viewsToFollowButtons()
            self.hideViewIfButtonIs()
        case .third:
            break
        }
    }
}
