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
    
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveView(gesture:)))
    
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
    
    lazy var viewOriginX = photosView.frame.origin.x
    lazy var viewOriginY = photosView.frame.origin.y

    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var photosView: PhotosView!
    
    @IBOutlet weak var instagridTitle: UITextView!
    @IBOutlet weak var instructionText: UITextView!
    
    @IBOutlet weak var thirdLayoutButton: UIButton!
    @IBOutlet weak var secondLayoutButton: UIButton!
    @IBOutlet weak var firstLayoutButton: UIButton!
    
    
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        photosView.changeLayout(from: currentLayout, to: .first, animated: true)
        currentLayout = .first
        selectedSign.frame = firstLayoutButton.frame
    }
    
    @IBAction func centerButtonTouched(_ sender: UIButton) {
        photosView.changeLayout(from: currentLayout, to: .second, animated: true)
        currentLayout = .second
        selectedSign.frame = secondLayoutButton.frame
    }

    @IBAction func rightButtonTouched(_ sender: UIButton) {
        photosView.changeLayout(from: currentLayout, to: .third, animated: true)
        currentLayout = .third
        selectedSign.frame = thirdLayoutButton.frame
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosView.addGestureRecognizer(panGestureRecognizer)
        
        picker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInRectangle), name: rectangleNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInRightButton), name: rightButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInLeftButton), name: leftButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInTopRightButton), name: topRightButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInTopLeftButton), name: topLeftButtonNotificationName, object: nil)
        
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
        
        adaptPhotosViewElementsToItsSize()
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
    
    // Sends notification that the phone rotated, and changes the swipe instruction text.
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
    
    // MARK: - Gesture
    
    @objc
    func moveView(gesture: UIPanGestureRecognizer) {
        var translationX = CGFloat()
        var translationY = CGFloat()
        let movement = gesture.translation(in: photosView)
        
        
        switch gesture.state {
        case .began, .changed:
            if abs(movement.x) < 25 && abs(movement.y) < 25 && orientation == .undefined {
                translationY = movement.y
                translationX = movement.x
                
                photosView.transform = CGAffineTransform(translationX: translationX, y: translationY)
            } else {
                if abs(movement.x) > abs(movement.y) && orientation == .undefined  { orientation = .horizontal }
                if abs(movement.y) > abs(movement.x) && orientation == .undefined  { orientation = .vertical }
                if orientation == .vertical {
                    translationX = 0
                    translationY = movement.y
                }
                if orientation == .horizontal {
                    translationY = 0
                    translationX = movement.x
                }
                
                if isPortrait {
                    if photosView.frame.origin.y < (viewOriginY-50) {
                        photosView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    } else {
                        photosView.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
                    }
                } else if isLandscape {
                    if photosView.frame.origin.x < (viewOriginX-50) {
                        photosView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    } else {
                        photosView.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
                    }
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.photosView.transform = CGAffineTransform(translationX: translationX, y: translationY)
                }
                )
            }
            
        case .ended, .cancelled:
            if isPortrait {
                if movement.y < -50 {
                    UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: {
                            self.photosView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1, animations: {
                            self.photosView.alpha = 0
                            self.photosView.transform = .identity
                            self.photosView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.01, animations: {
                            self.photosView.alpha = 1
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                            self.photosView.transform = .identity
                        })
                    }, completion: nil)
                    share()
                } else {
                    UIView.animate(withDuration: 0.3, animations: {self.photosView.transform = .identity})
                }
            } else if isLandscape {
                if movement.x < -50 {
                    UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: {
                            self.photosView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1, animations: {
                            self.photosView.alpha = 0
                            self.photosView.transform = .identity
                            self.photosView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.01, animations: {
                            self.photosView.alpha = 1
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                            self.photosView.transform = .identity
                        })
                    }, completion: nil)
                    share()
                } else {
                    UIView.animate(withDuration: 0.3, animations: {self.photosView.transform = .identity})
                }
            }
            orientation = .undefined
        default:
            break
        }
    }
    
    
    private func share() {
        photosView.backgroundColor = #colorLiteral(red: 0.7005076142, green: 0.7005076142, blue: 0.7005076142, alpha: 0.4212328767)
        guard let viewToShare = photosView.toUIImage() else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [viewToShare], applicationActivities: [])
        present(vc, animated: true)
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
    
    
    // Makes the layout button invisible (so they can look however we want in the IB) and puts the layout images in views on top of them. Adds the views to hierarchy, so is only to be called once.
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
    
    // Create constraints according to screen size and places buttons in the first layout. Also places the corresponding views.
    private func adaptPhotosViewElementsToItsSize() {
        photosView.rectangle.translatesAutoresizingMaskIntoConstraints = false
        photosView.rectangle.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*270.0/300.0)).isActive = true
        photosView.rectangle.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.rectangle.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.rectangle.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        
        photosView.rectangleView.translatesAutoresizingMaskIntoConstraints = false
        photosView.rectangleView.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*270.0/300.0)).isActive = true
        photosView.rectangleView.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.rectangleView.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.rectangleView.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        
        
        
        photosView.leftButton.translatesAutoresizingMaskIntoConstraints = false
        photosView.leftButton.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.leftButton.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.leftButton.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.leftButton.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*158.0/300.0)).isActive = true
        
        photosView.leftButtonView.translatesAutoresizingMaskIntoConstraints = false
        photosView.leftButtonView.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.leftButtonView.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.leftButtonView.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.leftButtonView.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*158.0/300.0)).isActive = true
        
        
        
        
        photosView.rightButton.translatesAutoresizingMaskIntoConstraints = false
        photosView.rightButton.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.rightButton.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.rightButton.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*156.0/300.0)).isActive = true
        photosView.rightButton.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*158.0/300.0)).isActive = true
        
        photosView.rightButtonView.translatesAutoresizingMaskIntoConstraints = false
        photosView.rightButtonView.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.rightButtonView.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.rightButtonView.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*156.0/300.0)).isActive = true
        photosView.rightButtonView.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*158.0/300.0)).isActive = true
        
        
        
        
        photosView.topLeftButton.translatesAutoresizingMaskIntoConstraints = false
        photosView.topLeftButton.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.topLeftButton.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.topLeftButton.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.topLeftButton.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.topLeftButton.alpha = 0
        
        photosView.topLeftButtonView.translatesAutoresizingMaskIntoConstraints = false
        photosView.topLeftButtonView.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.topLeftButtonView.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.topLeftButtonView.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.topLeftButtonView.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        
        
        
        
        photosView.topRightButton.translatesAutoresizingMaskIntoConstraints = false
        photosView.topRightButton.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.topRightButton.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.topRightButton.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*156.0/300.0)).isActive = true
        photosView.topRightButton.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        photosView.topRightButton.alpha = 0
        
        photosView.topRightButtonView.translatesAutoresizingMaskIntoConstraints = false
        photosView.topRightButtonView.widthAnchor.constraint(equalToConstant: CGFloat(photosView.frame.width*127.0/300.0)).isActive = true
        photosView.topRightButtonView.heightAnchor.constraint(equalToConstant: CGFloat(photosView.frame.height*127.0/300.0)).isActive = true
        photosView.topRightButtonView.leadingAnchor.constraint(equalTo: photosView.leadingAnchor, constant: CGFloat(photosView.frame.height*156.0/300.0)).isActive = true
        photosView.topRightButtonView.topAnchor.constraint(equalTo: photosView.topAnchor, constant: CGFloat(photosView.frame.height*17.0/300.0)).isActive = true
        
        let upMargin = photosView.frame.height*17.0/300.0
        let downMargin = photosView.frame.height*158.0/300.0
        let rightMargin = photosView.frame.width*17.0/300.0
        
        if photosView != nil {
            photosView.setPositionValues(up: upMargin, down: downMargin, right: rightMargin)
        }
    }
    
    // Uses text sizes functions with appropriate verifications
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

