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
    }

    // MARK: - Outlets
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topLeftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var topRightButton: UIButton!
    
    @IBOutlet weak var topRightButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var topRightButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var topLeftButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var topLeftButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var rightButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var rightButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var leftButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var leftButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var leftButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var leftButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var rightButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var rightButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var topLeftButtonTop: NSLayoutConstraint!
    @IBOutlet weak var topLeftButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var topRightButtonTop: NSLayoutConstraint!
    @IBOutlet weak var topRightButtonTrailing: NSLayoutConstraint!
    

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
    
    
    // MARK: - Public
    func setImage(_ photo: UIImage, for button: UIButton) {
        let imageView = UIImageView(image: photo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 0.0).isActive = true
        imageView.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 0.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 0.0).isActive = true
        imageView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 0.0).isActive = true
    }
    
    
    // MARK: - Configuration
    private func scalingLenghtToViewWidth(lenght: CGFloat) -> CGFloat {
        return lenght * self.frame.width / 300
    }
    
    private func scalingLenghtToViewHeight(lenght: CGFloat) -> CGFloat {
        return lenght * self.frame.height / 300
    }
    
    func setSizesAndPositionsOfElements() {
        setLeftButton()
        setRightButton()
        setTopLeftButton()
        setTopRightButton()
        
        setAndAddViews()
        setButtonsStyle()
        setViewsStyle()
    }

    
    private func setLeftButton() {
        guard let safeBottom = leftButtonBottom else { return }
        guard let safeLead = leftButtonLeading else { return }
        guard let safeWidth = leftButtonWidth else { return }
        guard let safeHeigth = leftButtonHeight else { return }
        
        safeBottom.constant = scalingLenghtToViewWidth(lenght: 17)
        safeLead.constant = scalingLenghtToViewWidth(lenght: 17)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeHeigth.constant = scalingLenghtToViewHeight(lenght: 127)
    }
    
    private func setTopLeftButton() {
        guard let safeTop = topLeftButtonTop else { return }
        guard let safeLead = topLeftButtonLeading else { return }
        guard let safeWidth = topLeftButtonWidth else { return }
        guard let safeHeigth = topLeftButtonHeight else { return }
        
        safeTop.constant = scalingLenghtToViewWidth(lenght: 17)
        safeLead.constant = scalingLenghtToViewWidth(lenght: 17)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeHeigth.constant = scalingLenghtToViewHeight(lenght: 127)
    }
    
    private func setRightButton() {
        guard let safeBottom = rightButtonBottom else { return }
        guard let safeTrail = rightButtonTrailing else { return }
        guard let safeWidth = rightButtonWidth else { return }
        guard let safeHeigth = rightButtonHeight else { return }
        
        safeBottom.constant = scalingLenghtToViewWidth(lenght: 17)
        safeTrail.constant = scalingLenghtToViewWidth(lenght: 13)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeHeigth.constant = scalingLenghtToViewHeight(lenght: 127)
    }
    
    private func setTopRightButton() {
        guard let safeTop = topRightButtonTop else { return }
        guard let safeTrail = topRightButtonTrailing else { return }
        guard let safeWidth = topRightButtonWidth else { return }
        guard let safeHeigth = topRightButtonHeight else { return }
        
        safeTop.constant = scalingLenghtToViewWidth(lenght: 17)
        safeTrail.constant = scalingLenghtToViewWidth(lenght: 13)
        safeWidth.constant = scalingLenghtToViewWidth(lenght: 127)
        safeHeigth.constant = scalingLenghtToViewHeight(lenght: 127)
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
