//
//  PhotosView2.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 24/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

class PhotosView2: UIView {

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
        Bundle.main.loadNibNamed("PhotosView2", owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleHeight, .flexibleWidth]        
    }
    
    // MARK: - Outlets

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var rectangle: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var rectangleWidth: NSLayoutConstraint!
    @IBOutlet weak var rectangleHeight: NSLayoutConstraint!
    @IBOutlet weak var leftButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var leftButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var rightButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var rightButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var rightButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var rightButtonTop: NSLayoutConstraint!
    @IBOutlet weak var leftButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var leftButtonTop: NSLayoutConstraint!
    @IBOutlet weak var rectangleLeading: NSLayoutConstraint!
    @IBOutlet weak var rectangleBottom: NSLayoutConstraint!
    @IBAction func rectangleButtonTouched(_ sender: UIButton) {
        sendNotification("rectangle")
    }
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        sendNotification("leftButton")
    }
    @IBAction func rightButtonTouched(_ sender: UIButton) {
        sendNotification("rightButton")
    }

    
    // MARK: - Properties
    
    private lazy var buttons = [rectangle, leftButton, rightButton]
    private lazy var views = [rectangleView, leftButtonView, rightButtonView]
    
    lazy var rectangleView = UIImageView()
    lazy var leftButtonView = UIImageView()
    lazy var rightButtonView = UIImageView()
    
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
    
    func setSizesAndPositionsOfElements() {
        setRectangleButton()
        setLeftButton()
        setRightButton()
        
        setAndAddViews()
        setButtonsStyle()
        setViewsStyle()
    }
    
    private func setRectangleButton() {
        guard let safeBottom = rectangleBottom else { return }
        guard let safeWidth = rectangleWidth else { return }
        guard let safeLeading = rectangleLeading else { return }
        guard let safeHeight = rectangleHeight else { return }
        
        safeBottom.constant = scalingLenghtToViewHeight(lenght: 13)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 270)
        safeLeading.constant = scalingLenghtToViewWidth(lenght: 17)
        safeHeight.constant = scalingLenghtToViewHeight(lenght: 127)
    }
    
    private func setLeftButton() {
        guard let safeTop = leftButtonTop else { return }
        guard let safeWidth = leftButtonWidth else { return }
        guard let safeLeading = leftButtonLeading else { return }
        guard let safeHeight = leftButtonHeight else { return }
        
        safeTop.constant = scalingLenghtToViewHeight(lenght: 17)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeLeading.constant = scalingLenghtToViewWidth(lenght: 17)
        safeHeight.constant = scalingLenghtToViewHeight(lenght: 127)
    }

    private func setRightButton() {
        guard let safeTop = rightButtonTop else { return }
        guard let safeWidth = rightButtonWidth else { return }
        guard let safeTrail = rightButtonTrailing else { return }
        guard let safeHeight = rightButtonHeight else { return }
        
        safeTop.constant = scalingLenghtToViewHeight(lenght: 17)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeTrail.constant = scalingLenghtToViewWidth(lenght: 13)
        safeHeight.constant = scalingLenghtToViewHeight(lenght: 127)
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
            guard let label = safeButton.titleLabel else { return }
            
            safeButton.setTitle("+", for: [])
            label.font = label.font.withSize(77)
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
