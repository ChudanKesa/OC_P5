//
//  ViewController.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 02/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit
import MobileCoreServices

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    lazy var currentDeviceOrientation = UIDeviceOrientation.unknown
    
    lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage as String]
        picker.modalPresentationStyle = .overCurrentContext
        return picker
    }()
    
    lazy var rectangleNotificationName = NSNotification.Name(rawValue: "rectangle")
    lazy var rightButtonNotificationName = NSNotification.Name(rawValue: "rightButton")
    lazy var leftButtonNotificationName = NSNotification.Name(rawValue: "leftButton")
    lazy var topRightButtonNotificationName = NSNotification.Name(rawValue: "topRightButton")
    lazy var topLeftButtonNotificationName = NSNotification.Name(rawValue: "topLeftButton")
    
    lazy var currentImageViewToFill = UIImageView()
    lazy var associatedButton = UIButton()
    
    var photosViewWidth: CGFloat?
    var photosViewHeight: CGFloat?
    var instagridTitleWidth: CGFloat?
    var instagridTitleHeight: CGFloat?
    var instructionTextWidth: CGFloat?
    var instructionTextHeight: CGFloat?
    var buttonWidth: CGFloat?
    var buttonHeight: CGFloat?
    
    lazy var isPortrait = false
    lazy var isLandscape = false
    
    lazy var firstLayoutButtonView = UIImageView()
    lazy var secondLayoutButtonView = UIImageView()
    lazy var thirdLayoutButtonView = UIImageView()
    
    lazy var selectedSign = UIImageView()
    
    enum direction: String {
        case horizontal, vertical, undefined
    }
    lazy var orientation = direction.undefined
    lazy var currentLayout = PhotosView.layout.first

    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var photosView: PhotosView!
    
    @IBOutlet weak var instagridTitle: UITextView!
    @IBOutlet weak var instructionText: UITextView!
    
    @IBOutlet weak var thirdLayoutButton: UIButton!
    @IBOutlet weak var secondLayoutButton: UIButton!
    @IBOutlet weak var firstLayoutButton: UIButton!
    
    
    @IBAction func rightButtonTouched(_ sender: UIButton) {
    }
    @IBAction func centerButtonTouched(_ sender: UIButton) {
    }
    @IBAction func leftButtonTouched(_ sender: UIButton) {
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(notification:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setFontSize(of: instagridTitle)
        setFontSize(of: instructionText)
        
        var alreadySet = false
        let subviews = self.view.subviews
        
        for subview in subviews.indices {
            if subviews[subview] == firstLayoutButtonView { alreadySet = true }
        }
        if !alreadySet { setButtonsViews() }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scaleViews()
    }
    
    
    // MARK: - Notifications
    
    @objc
    func putPictureInRectangle() {
        currentImageViewToFill = self.photosView.rectangleView
        associatedButton = self.photosView.rectangle
        choosePicture()
    }
    @objc
    func putPictureInRightButton() {
        currentImageViewToFill = self.photosView.rightButtonView
        associatedButton = self.photosView.rightButton
        choosePicture()
    }
    @objc
    func putPictureInLeftButton() {
        currentImageViewToFill = self.photosView.leftButtonView
        associatedButton = self.photosView.leftButton
        choosePicture()
    }
    @objc
    func putPictureInTopRightButton() {
        currentImageViewToFill = self.photosView.topRightButtonView
        associatedButton = self.photosView.topRightButton
        choosePicture()
    }
    @objc
    func putPictureInTopLeftButton() {
        currentImageViewToFill = self.photosView.topLeftButtonView
        associatedButton = self.photosView.topLeftButton
        choosePicture()
    }
    
    @objc
    func deviceDidRotate(notification: Notification) {
        self.currentDeviceOrientation = UIDevice.current.orientation
        // Ignore changes in device orientation if unknown, face up, or face down.
        if !UIDeviceOrientationIsValidInterfaceOrientation(currentDeviceOrientation) {
            return;
        }
        
        self.isLandscape = UIDeviceOrientationIsLandscape(currentDeviceOrientation);
        self.isPortrait = UIDeviceOrientationIsPortrait(currentDeviceOrientation);
        
        if isLandscape {
            adaptButtonsViewsToPhoneRotation()
            if instructionText != nil {
                instructionText.text = "<\nSwipe left to share"
            }
        }
        if isPortrait {
            adaptButtonsViewsToPhoneRotation()
            if instructionText != nil {
                instructionText.text = "^\nSwipe up to share"
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
            self.currentImageViewToFill.alpha = 1
            self.currentImageViewToFill.contentMode = .scaleAspectFill
            self.currentImageViewToFill.layer.masksToBounds = true
            self.currentImageViewToFill.clipsToBounds = true
            self.currentImageViewToFill.image = photo
            self.photosView.setButtonStyle(button: self.associatedButton, style: self.photosView.invisibleStyle)
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func choosePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Configuration

    // Reccords views sizes according to screen size
    private func initSizesValues() {
        if photosView != nil {
            photosViewHeight = self.view.frame.height*300.0/736.0
            photosViewWidth = self.view.frame.width*300.0/414.0
        } else {
            fatalError("\n**** photosView didn't load.\n")
        }
        if instagridTitle != nil {
            instagridTitleHeight = self.view.frame.height*44.0/736.0
            instagridTitleWidth = self.view.frame.width*119.0/414.0
        } else {
            fatalError("\n**** instagridTitle didn't load.\n")
        }
        if instructionText != nil {
            instructionTextHeight = self.view.frame.height*90.0/736.0
            instructionTextWidth = self.view.frame.width*161.0/414.0
        } else {
            fatalError("\n**** instructionText didn't load.\n")
        }
        if thirdLayoutButton != nil && secondLayoutButton != nil && firstLayoutButton != nil {
            buttonHeight = self.view.frame.height*80.0/736.0
            buttonWidth = self.view.frame.width*80.0/414.0
            
            buttonHeight = self.view.frame.height*80.0/736.0
            buttonWidth = self.view.frame.width*80.0/414.0
            
            buttonHeight = self.view.frame.height*80.0/736.0
            buttonWidth = self.view.frame.width*80.0/414.0
        } else {
            fatalError("\n**** buttons didn't load.\n")
        }
    }
    
    private func setButtonsViews() {
        
        self.view.addSubview(firstLayoutButtonView)
        self.view.addSubview(secondLayoutButtonView)
        self.view.addSubview(thirdLayoutButtonView)
        
        self.view.addSubview(selectedSign)
        selectedSign.frame = firstLayoutButton.frame
        selectedSign.contentMode = .scaleAspectFill
        selectedSign.layer.masksToBounds = true
        selectedSign.clipsToBounds = true
        selectedSign.image = UIImage(named: "Selected")
        selectedSign.isUserInteractionEnabled = false
        selectedSign.layer.zPosition = 2
        
        firstLayoutButtonView.frame = firstLayoutButton.frame
        secondLayoutButtonView.frame = secondLayoutButton.frame
        thirdLayoutButtonView.frame = thirdLayoutButton.frame
        
        
        photosView.setButtonStyle(button: firstLayoutButton, style: photosView.invisibleStyle)
        photosView.setButtonStyle(button: secondLayoutButton, style: photosView.invisibleStyle)
        photosView.setButtonStyle(button: thirdLayoutButton, style: photosView.invisibleStyle)
        
        firstLayoutButtonView.contentMode = .scaleAspectFill
        firstLayoutButtonView.layer.masksToBounds = true
        firstLayoutButtonView.clipsToBounds = true
        firstLayoutButtonView.image = UIImage(named: "Layout 1")
        firstLayoutButtonView.isUserInteractionEnabled = false
        firstLayoutButtonView.layer.zPosition = 1
        
        secondLayoutButtonView.contentMode = .scaleAspectFill
        secondLayoutButtonView.layer.masksToBounds = true
        secondLayoutButtonView.clipsToBounds = true
        secondLayoutButtonView.image = UIImage(named: "Layout 2")
        secondLayoutButtonView.isUserInteractionEnabled = false
        secondLayoutButtonView.layer.zPosition = 1
        
        thirdLayoutButtonView.contentMode = .scaleAspectFill
        thirdLayoutButtonView.layer.masksToBounds = true
        thirdLayoutButtonView.clipsToBounds = true
        thirdLayoutButtonView.image = UIImage(named: "Layout 3")
        thirdLayoutButtonView.isUserInteractionEnabled = false
        thirdLayoutButtonView.layer.zPosition = 1
    }
    
    // Sets views sizes to reccorded values
    private func setSizes() {
        
        if photosView != nil {
            for constraint in photosView.constraints {
                if constraint.identifier == "idPhotosViewWidth" {
                    constraint.constant = photosViewWidth!
                }
            }
        } else {
            fatalError("\n**** photosView didn't load.\n")
        }
        if instagridTitle != nil {
            for constraint in instagridTitle.constraints {
                if constraint.identifier == "idInstaTitleWidth" {
                    constraint.constant = instagridTitleWidth!
                }
                if constraint.identifier == "idInstaTitleHeight" {
                    constraint.constant = instagridTitleHeight!
                }
            }
        } else {
            fatalError("\n**** instagridTitle didn't load.\n")
        }
        if instructionText != nil {
            for constraint in instructionText.constraints {
                if constraint.identifier == "idInstructWidth" {
                    constraint.constant = instructionTextWidth!
                }
            }
        } else {
            fatalError("\n**** instructionText didn't load.\n")
        }
        if thirdLayoutButton != nil && secondLayoutButton != nil && firstLayoutButton != nil {
            for constraint in thirdLayoutButton.constraints {
                if constraint.identifier == "idButtonWidth" {
                    constraint.constant = buttonWidth!
                }
            }
            for constraint in secondLayoutButton.constraints {
                if constraint.identifier == "idButtonWidth" {
                    constraint.constant = buttonWidth!
                }
            }
            for constraint in firstLayoutButton.constraints {
                if constraint.identifier == "idButtonWidth" {
                    constraint.constant = buttonWidth!
                }
            }
        } else {
            fatalError("\n**** buttons didn't load.\n")
        }
    }
    
    
    // Sets the textViews font sizes according to screen size
    private func setFontSize(of textView: UITextView) {
        if textView.font != nil {
            let size: CGFloat = self.view.frame.width*(23.0/414.0)
            var font = UIFont()
            if textView === instagridTitle {
                guard let titleFont = UIFont(name: "ThirstySoftRegular", size: size) else { return }
                font = titleFont
            }
            if textView === instructionText {
                guard let instFont = UIFont(name: "Delm-Medium", size: size) else { return }
                font = instFont
            }
            textView.font! = font
        }
    }
    
    // Uses views sizes functions with appropriate verifications
    private func scaleViews() {
        if instagridTitleWidth == nil {
            initSizesValues()
        }
        if instagridTitleWidth != nil {
            setSizes()
        } else {
            fatalError("\n**** Sizes init didn't work.\n")
        }
    }
    
    // The views covering the layout buttons don't have constraints, this places them.
    // -> to be used in deviceDidRotate()
    private func adaptButtonsViewsToPhoneRotation() {
        firstLayoutButtonView.frame = firstLayoutButton.frame
        secondLayoutButtonView.frame = secondLayoutButton.frame
        thirdLayoutButtonView.frame = thirdLayoutButton.frame
        switch currentLayout {
        case .first:
            selectedSign.frame = firstLayoutButtonView.frame
        case .second:
            selectedSign.frame = secondLayoutButtonView.frame
        case .third:
            selectedSign.frame = thirdLayoutButtonView.frame
        }
    }
    
    
    // MARK: - Support
    
    private func printDetails() {
        print ("\nphotosView.width: \(photosView.frame.width)\nphotosView.height: \(photosView.frame.height)\nratio.width: \(photosView.frame.width)/\(self.view.frame.width)\nratio.height: \(photosView.frame.height)/\(self.view.frame.height)\n\ninstagridTitle.width: \(instagridTitle.frame.width)\ninstagridTitle.height: \(instagridTitle.frame.height)\nratio.width: \(instagridTitle.frame.width)/\(self.view.frame.width)\nratio.height: \(instagridTitle.frame.height)/\(self.view.frame.height)\n\nrightButton.width: \(thirdLayoutButton.frame.width)\nrightButton.height: \(thirdLayoutButton.frame.height)\nratio.width: \(thirdLayoutButton.frame.width)/\(self.view.frame.width)\nratio.height: \(thirdLayoutButton.frame.height)/\(self.view.frame.height)\n\ninstructionText.width: \(instructionText.frame.width)\ninstructionText.height: \(instructionText.frame.height)\nratio.width: \(instructionText.frame.width)/\(self.view.frame.width)\nratio.height: \(instructionText.frame.height)/\(self.view.frame.height)")
    }

}

