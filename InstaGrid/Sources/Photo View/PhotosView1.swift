
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
        
        setSizesAndPositionsOfElements()
    }

    // MARK: - Properties
    private lazy var buttons = [rectangle, leftButton, rightButton]
    private lazy var views = [rectangleView, leftButtonView, rightButtonView]
    
    lazy var rectangleView = UIImageView()
    lazy var leftButtonView = UIImageView()
    lazy var rightButtonView = UIImageView()
    
    // MARK: - Outlets & actions
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var rectangle: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBAction func rectangleButtonTouched(_ sender: UIButton) {
        sendNotification("rectangle")
    }
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        sendNotification("leftButton")
    }
    @IBAction func rightButtonTouched(_ sender: UIButton) {
        sendNotification("rightButton")
    }
    
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
    
    private func setSizesAndPositionsOfElements() {
        setRectangleButton()
        setLeftButton()
        setRightButton()
        
        setAndAddViews()
        setButtonsStyle()
        setViewsStyle()
    }
    
    private func setRectangleButton() {
        guard let safeRectangle = rectangle else { return }
        let frame = CGRect(x: 17.0, y: 17.0, width: scalingLenghtToViewWidth(lenght: 270.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeRectangle.frame = frame
    }
    
    private func setLeftButton() {
        guard let safeLeftButton = leftButton else { return }
        let frame = CGRect(x: 17.0, y: 160.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeLeftButton.frame = frame
    }
    
    private func setRightButton() {
        guard let safeRightButton = leftButton else { return }
        let frame = CGRect(x: 160.0, y: 160.0, width: scalingLenghtToViewWidth(lenght: 127.0), height: scalingLenghtToViewHeight(lenght: 127.0))
        safeRightButton.frame = frame
    }
    
    private func setAndAddViews() {
        setRectangleView()
        setLeftButtonView()
        setRightButtonView()
        
        self.addSubview(rectangleView)
        self.addSubview(leftButtonView)
        self.addSubview(rightButtonView)
    }
    
    private func setRectangleView() {
        guard let safeRectangle = rectangle else { return }
        
        rectangleView.translatesAutoresizingMaskIntoConstraints = false
        rectangleView.frame = safeRectangle.frame
    }
    
    private func setLeftButtonView() {
        guard let safeLeftButton = leftButton else { return }
        
        leftButtonView.translatesAutoresizingMaskIntoConstraints = false
        leftButtonView.frame = safeLeftButton.frame
    }
    
    private func setRightButtonView() {
        guard let safeRightButton = rightButton else { return }
        
        rightButtonView.translatesAutoresizingMaskIntoConstraints = false
        rightButtonView.frame = safeRightButton.frame
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
