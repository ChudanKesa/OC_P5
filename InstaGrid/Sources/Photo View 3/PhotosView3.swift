//
//  PhotosViews3.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 24/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

class PhotosView3: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PhotosView3", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        setSizesPositionsAndStylesOfElements()
    }

    // MARK: - Outlets
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topLeftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var topRightButton: UIButton!
    

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
    
    // MARK: - Properties
    
    private lazy var buttons = [leftButton, topLeftButton, rightButton, topRightButton]
    private lazy var views = [leftButtonView, topLeftButtonView, rightButtonView, topRightButtonView]
    
    lazy var leftButtonView = UIImageView()
    lazy var topLeftButtonView = UIImageView()
    lazy var rightButtonView = UIImageView()
    lazy var topRightButtonView = UIImageView()
    
    // MARK: - Notification
    
    private func sendNotification(_ name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    // MARK: - Configuration
    private func scalingLenghtToViewWidth(lenght: CGFloat) -> CGFloat {
        return lenght * self.frame.width / 300
    }
    
    private func scalingLenghtToViewHeight(lenght: CGFloat) -> CGFloat {
        return lenght * self.frame.height / 300
    }
    
    private func setSizesPositionsAndStylesOfElements() {
        setLeftButton()
        setRightButton()
        setTopLeftButton()
        setTopRightButton()
        
        setAndAddViews()
        setButtonsStyle()
        setViewsStyle()
    }

    
    private func setLeftButton() {
        guard let safeLeftButton = leftButton else { return }
        let frame = CGRect(x: 17.0, y: 160.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeLeftButton.frame = frame
    }
    
    private func setTopLeftButton() {
        guard let safeTopLeftButton = leftButton else { return }
        let frame = CGRect(x: 17.0, y: 17.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeTopLeftButton.frame = frame
    }
    
    private func setRightButton() {
        guard let safeRightButton = leftButton else { return }
        let frame = CGRect(x: 160.0, y: 17.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeRightButton.frame = frame
    }
    
    private func setTopRightButton() {
        guard let safeTopRightButton = leftButton else { return }
        let frame = CGRect(x: 160.0, y: 160.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeTopRightButton.frame = frame
    }
    
    private func setAndAddViews() {
        setViews()
        
        self.addSubview(leftButtonView)
        self.addSubview(topLeftButtonView)
        self.addSubview(rightButtonView)
        self.addSubview(topRightButtonView)
    }
    
    
    private func setViews() {
        for index in views.indices {
            guard let safeButton = buttons[index] else { return }
            
            views[index].translatesAutoresizingMaskIntoConstraints = false
            views[index].frame = safeButton.frame
        }
    }
    
    private func setButtonsStyle() {
        for button in buttons {
            guard let safeButton = button else { return }
            
            safeButton.setTitle("+", for: [])
            safeButton.setTitleColor(#colorLiteral(red: 0.323646307, green: 0.5646677017, blue: 0.7364179492, alpha: 1), for: [])
            safeButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    private func setViewsStyle() {
        for view in views {
            view.isUserInteractionEnabled = false
            view.alpha = 0
        }
    }
}
