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
    
    private lazy var currentDeviceOrientation = UIDeviceOrientation.unknown
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveView(gesture:)))
    
    private lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage as String]
        picker.modalPresentationStyle = .overCurrentContext
        return picker
    }()
    
    private lazy var rectangleNotificationName = NSNotification.Name(rawValue: "rectangle")
    private lazy var rightButtonNotificationName = NSNotification.Name(rawValue: "rightButton")
    private lazy var leftButtonNotificationName = NSNotification.Name(rawValue: "leftButton")
    private lazy var topRightButtonNotificationName = NSNotification.Name(rawValue: "topRightButton")
    private lazy var topLeftButtonNotificationName = NSNotification.Name(rawValue: "topLeftButton")
    
    private lazy var currentImageViewToFill = UIImageView()
    private lazy var associatedButton = UIButton()
    
    private var photosViewWidth: CGFloat?
    private var photosViewHeight: CGFloat?
    private var instagridTitleWidth: CGFloat?
    private var instagridTitleHeight: CGFloat?
    private var instructionTextWidth: CGFloat?
    private var instructionTextHeight: CGFloat?
    private var buttonWidth: CGFloat?
    private var buttonHeight: CGFloat?
    
    private lazy var isPortrait = false
    private lazy var isLandscape = false
    
    private lazy var firstLayoutButtonView = UIImageView()
    private lazy var secondLayoutButtonView = UIImageView()
    private lazy var thirdLayoutButtonView = UIImageView()
    
    private lazy var selectedSign = UIImageView()
    
    private enum direction {
        case horizontal, vertical, undefined
    }
    private lazy var orientation = direction.undefined
    private lazy var currentLayout = PhotosView.layout.first
    
    private lazy var viewOriginX = photosViewsContainer.frame.origin.x
    private lazy var viewOriginY = photosViewsContainer.frame.origin.y
    
    private lazy var photosView1 = PhotosView()
    private lazy var photosView2 = PhotosView2()
    private lazy var photosView3 = PhotosView3()

    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var photosViewsContainer: UIView!
    
    @IBOutlet weak var instagridTitle: UITextView!
    @IBOutlet weak var instructionText: UITextView!
    
    @IBOutlet weak var thirdLayoutButton: UIButton!
    @IBOutlet weak var secondLayoutButton: UIButton!
    @IBOutlet weak var firstLayoutButton: UIButton!
    
    
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        photosViewsContainer.addSubview(photosView1)
        currentLayout = .first
        selectedSign.frame = firstLayoutButton.frame
    }
    
    @IBAction func centerButtonTouched(_ sender: UIButton) {
        photosViewsContainer.addSubview(photosView2)
        currentLayout = .second
        selectedSign.frame = secondLayoutButton.frame
    }

    @IBAction func rightButtonTouched(_ sender: UIButton) {
        photosViewsContainer.addSubview(photosView3)
        currentLayout = .third
        selectedSign.frame = thirdLayoutButton.frame
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosViewsContainer.addGestureRecognizer(panGestureRecognizer)
        picker.delegate = self
        addNotificationObserversToViewControler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setFontSize(of: instagridTitle)
        setFontSize(of: instructionText)
        
        var alreadySet = false
        guard let viewControlerView = self.view else { return }
        let subviews = viewControlerView.subviews
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
    
    private func addNotificationObserversToViewControler() {
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInRectangle), name: rectangleNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInRightButton), name: rightButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInLeftButton), name: leftButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInTopRightButton), name: topRightButtonNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(putPictureInTopLeftButton), name: topLeftButtonNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(notification:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc
    private func putPictureInRectangle() {
        currentImageViewToFill = self.photosViewsContainer.rectangleView
        associatedButton = self.photosViewsContainer.rectangle
        choosePicture()
    }
    @objc
    private func putPictureInRightButton() {
        currentImageViewToFill = self.photosViewsContainer.rightButtonView
        associatedButton = self.photosViewsContainer.rightButton
        choosePicture()
    }
    @objc
    private func putPictureInLeftButton() {
        currentImageViewToFill = self.photosViewsContainer.leftButtonView
        associatedButton = self.photosViewsContainer.leftButton
        choosePicture()
    }
    @objc
    private func putPictureInTopRightButton() {
        currentImageViewToFill = self.photosViewsContainer.topRightButtonView
        associatedButton = self.photosViewsContainer.topRightButton
        choosePicture()
    }
    @objc
    private func putPictureInTopLeftButton() {
        currentImageViewToFill = self.photosViewsContainer.topLeftButtonView
        associatedButton = self.photosViewsContainer.topLeftButton
        choosePicture()
    }
    
    // Sends notification that the phone rotated, and changes the swipe instruction text.
    @objc
    private func deviceDidRotate(notification: Notification) {
        self.currentDeviceOrientation = UIDevice.current.orientation
        // Ignore changes in device orientation if unknown, face up, or face down.
        if !UIDeviceOrientationIsValidInterfaceOrientation(currentDeviceOrientation) {
            return;
        }
        
        self.isLandscape = UIDeviceOrientationIsLandscape(currentDeviceOrientation);
        self.isPortrait = UIDeviceOrientationIsPortrait(currentDeviceOrientation);
        
        adaptInstructionTextToPhoneOrientation()
        adaptButtonsViewsToPhoneRotation()
    }
    
    private func adaptInstructionTextToPhoneOrientation() {
        isLandscape ? printLandscapeText() : printPortraitText()
    }
    
    private func printLandscapeText() {
        guard let textOfInstruction = instructionText else { return }
        textOfInstruction.text = "<\nSwipe left to share"
    }
    
    private func printPortraitText() {
        guard let textOfInstruction = instructionText else { return }
       textOfInstruction.text = "^\nSwipe up to share"
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
            photoSetting(photo)
            guard let photosContainer = self.photosViewsContainer  else { return }
            photosContainer.setButtonStyle(button: self.associatedButton, style: self.photosView.invisibleStyle)
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func choosePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }

    
    
    // MARK: - Gesture
    // Makes photosView move according to settings.
    @objc
    private func moveView(gesture: UIPanGestureRecognizer) {
        guard let movingPhotosView = self.photosViewsContainer else { return }
        
        switch gesture.state {
        case .began, .changed:
            setMovementBehavior(of: gesture.translation(in: movingPhotosView))
            
        case .ended, .cancelled:
            callShareAndCenterView(from: gesture.translation(in: movingPhotosView))
        default:
            break
        }
    }
    
    // Calls sharing and centering functions based on orientation. Sets orientation back to undefined.
    private func callShareAndCenterView(from movement: CGPoint) {
        isPortrait ? portraitViewHandling(from: movement) : landscapeViewHandling(from: movement)
        orientation = .undefined
    }
    
    // Sets background back to original color and shares view.
    private func share() {
        guard let mainPhotosView = photosViewsContainer else { return }
        mainPhotosView.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
        guard let viewToShare = mainPhotosView.toUIImage() else { return }
        
        let vc = UIActivityViewController(activityItems: [viewToShare], applicationActivities: [])
        present(vc, animated: true)
    }
    
    
    // Calls orientation setting and makes photosView move straight. Also color view's backround if needed.
    private func moveViewStraight(whithMovement movement: CGPoint) {
        setOrientation(basedOn: movement, isNeeded: orientation == .undefined ? true : false)
        photosViewsContainer.transform = CGAffineTransform(translationX: orientation == .horizontal ? movement.x : 0, y: orientation == .vertical ? movement.y : 0)
        colorPhotosView()
    }
    
    // Checks if photosView can move freely or if movement has to be set.
    private func setMovementBehavior(of movement: CGPoint) {
        abs(movement.x) < 25 && abs(movement.y) < 25 && orientation == .undefined ? photosViewsContainer.transform = CGAffineTransform(translationX: movement.x, y: movement.y) : moveViewStraight(whithMovement: movement)
    }
    
    // Sets orientation if it's not already.
    private func setOrientation(basedOn movement: CGPoint, isNeeded: Bool) {
        orientation = isNeeded ? abs(movement.x) >= abs(movement.y) ? .horizontal : .vertical : orientation
    }
    
    // Animates photosView up out of view and back in the middle.
    private func animateViewAwayAndBackOnYAxis() {
        guard let view = self.photosViewsContainer else { return }
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            guard let strongSelf = self else { return }
            guard let strongSelfView = strongSelf.view else { return }
            view.transform = CGAffineTransform(translationX: 0, y: -strongSelfView.frame.height)
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    view.transform = .identity
                }, completion: nil)
        })
    }
    
    // Animates photosView left out of view and back in the middle.
    private func animateViewAwayAndBackOnXAxis() {
        guard let view = self.photosViewsContainer else { return }
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            guard let strongSelf = self else { return }
            guard let strongSelfView = strongSelf.view else { return }
            view.transform = CGAffineTransform(translationX: -strongSelfView.frame.width, y: 0)
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    view.transform = .identity
                }, completion: nil)
        })
    }
    
    // Calls animation for Y axis and shares image.
    private func animateViewUpAndShare() {
        animateViewAwayAndBackOnYAxis()
        share()
    }
    
    // Calls animation for X axis and shares image.
    private func animateViewLeftAndShare() {
        animateViewAwayAndBackOnXAxis()
        share()
    }
    
    // Simply put view back to .identity. Only exists for clearer reading of calling functions.
    private func animateViewBackToIdentity() {
        UIView.animate(withDuration: 0.3, animations: {self.photosViewsContainer.transform = .identity})
    }
    
    // Decides wheter view should be shared or go back in original place on portrait mode.
    private func portraitViewHandling(from movement: CGPoint) {
        movement.y < -50 && orientation == .vertical ? animateViewUpAndShare() : animateViewBackToIdentity()
    }
    
    // Decides wheter view should be shared or go back in original place on landscape mode.
    private func landscapeViewHandling(from movement: CGPoint) {
        movement.x < -50 && orientation == .horizontal ? animateViewLeftAndShare() : animateViewBackToIdentity()
    }
    
    // MARK: - Configuration
    // Reccords views sizes according to screen size
    private func initSizesValues() {
        guard let controlerView = self.view else { return }

        photosViewsContainer != nil ? photosViewSizeSetting(accordingTo: controlerView) : callsFatalError(withMessage: "\n**** photosView didn't load.\n")
        
        instagridTitle != nil ? instagridTitleSizeSetting(accordingTo: controlerView) : callsFatalError(withMessage: "instaGrid Title didn't load.\n")
        
        instructionText != nil ? instagridTitleSizeSetting(accordingTo: controlerView) : callsFatalError(withMessage: "instructionText didn't load.\n")
        
        thirdLayoutButton != nil && secondLayoutButton != nil && firstLayoutButton != nil ? layoutButtonSizeSetting(accordingTo: controlerView) : callsFatalError(withMessage: "Layout buttons didn't load.\n")
    }
    
    private func photosViewSizeSetting(accordingTo constrolerView: UIView) {
        photosViewHeight = constrolerView.frame.height*300.0/736.0
        photosViewWidth = constrolerView.frame.width*300.0/414.0
    }
    
    private func instagridTitleSizeSetting(accordingTo controlerView: UIView) {
        instagridTitleHeight = controlerView.frame.height*44.0/736.0
        instagridTitleWidth = controlerView.frame.width*119.0/414.0
    }
    
    private func instructionTextSizeSetting(accordingTo controlerView: UIView) {
        instructionTextHeight = controlerView.frame.height*90.0/736.0
        instructionTextWidth = controlerView.frame.width*161.0/414.0
    }
    
    private func layoutButtonSizeSetting(accordingTo controlerView: UIView) {
        buttonHeight = controlerView.frame.height*80.0/736.0
        buttonWidth = controlerView.frame.width*80.0/414.0
        
        buttonHeight = controlerView.frame.height*80.0/736.0
        buttonWidth = controlerView.frame.width*80.0/414.0
        
        buttonHeight = controlerView.frame.height*80.0/736.0
        buttonWidth = controlerView.frame.width*80.0/414.0
    }
    
    // So as to be able to fatalError in ternary operator (since it won't accept a "Never" type as argument).
    private func callsFatalError(withMessage problem: String) {
        fatalError(problem)
    }
    
    
    // Sets views sizes to reccorded values
    private func setSizes() {
        setSizeOfPhotosView()
        setSizeOfInstagridTitle()
        setSizeofInstructionText()
        setSizeOfLayoutButtons()
    }
    
    private func setSizeOfPhotosView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let viewOfPhotsWidth = photosViewWidth else { return }
        for constraint in viewOfPhotos.constraints {
            guard let identifier = constraint.identifier else { return }
            if identifier == "idPhotosViewWidth" {
                constraint.constant = viewOfPhotsWidth
            }
        }
    }
    
    private func setSizeOfInstagridTitle() {
        guard let gridTitle = instagridTitle else { return }
        guard let gridTitleWidth = instagridTitleWidth else { return }
        guard let gridTitleHeight = instagridTitleHeight else { return }
        for constraint in gridTitle.constraints {
            guard let identifier = constraint.identifier else { return }
            if identifier == "idInstaTitleWidth" {
                constraint.constant = gridTitleWidth
            }
            if identifier == "idInstaTitleHeight" {
                constraint.constant = gridTitleHeight
            }
        }
    }
    
    private func setSizeofInstructionText() {
        guard let textOfInstruction = instructionText else { return }
        guard let textOfInstructionWidth = instructionTextWidth else { return }
        for constraint in textOfInstruction.constraints {
            guard let identifier = constraint.identifier else { return }
            if identifier == "idInstructWidth" {
                constraint.constant = textOfInstructionWidth
            }
        }
    }
    
    private func setSizeOfLayoutButtons() {
        guard let firstButton = firstLayoutButton else { return }
        guard let secondButton = secondLayoutButton else { return }
        guard let thirdButton = thirdLayoutButton else { return }
        guard let layoutButtonWidth = buttonWidth else { return }
        let array = [firstButton, secondButton, thirdButton]
        for button in array {
            for constraint in button.constraints {
                guard let identifier = constraint.identifier else { return }
                if identifier == "idButtonWidth" {
                    constraint.constant = layoutButtonWidth
                }
            }
        }
    }
    

    
    // Makes the layout button invisible (so they can look however we want in the IB) and puts the layout images in views on top of them. Adds the views to hierarchy, so is only to be called once.
    private func setButtonsViews() {
        addLayoutButtonSubviews()
        selectedSignSetting()
        setButtonsStyle()
        layoutButtonsViewsFrameSetting()
        layoutButtonsViewsSetting()
    }
    
    private func addLayoutButtonSubviews() {
        guard let view = self.view else { return }
        view.addSubview(firstLayoutButtonView)
        view.addSubview(secondLayoutButtonView)
        view.addSubview(thirdLayoutButtonView)
    }
    
    private func selectedSignSetting() {
        guard let view = self.view else { return }
        view.addSubview(selectedSign)
        selectedSign.frame = firstLayoutButton.frame
        selectedSign.contentMode = .scaleAspectFill
        selectedSign.layer.masksToBounds = true
        selectedSign.clipsToBounds = true
        selectedSign.image = UIImage(named: "Selected")
        selectedSign.isUserInteractionEnabled = false
        selectedSign.layer.zPosition = 2
    }
    
    private func setButtonsStyle() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        viewOfPhotos.setButtonStyle(button: firstLayoutButton, style: photosView.invisibleStyle)
        viewOfPhotos.setButtonStyle(button: secondLayoutButton, style: photosView.invisibleStyle)
        viewOfPhotos.setButtonStyle(button: thirdLayoutButton, style: photosView.invisibleStyle)
    }
    
    private func layoutButtonsViewsFrameSetting() {
        firstLayoutButtonView.frame = firstLayoutButton.frame
        secondLayoutButtonView.frame = secondLayoutButton.frame
        thirdLayoutButtonView.frame = thirdLayoutButton.frame
    }
    
    private func layoutButtonsViewsSetting() {
        firstLayoutButtonSetting()
        secondLayoutButtonSetting()
        thirdLayoutButtonSetting()
    }
    
    private func firstLayoutButtonSetting() {
        firstLayoutButtonView.contentMode = .scaleAspectFill
        firstLayoutButtonView.layer.masksToBounds = true
        firstLayoutButtonView.clipsToBounds = true
        firstLayoutButtonView.image = UIImage(named: "Layout 1")
        firstLayoutButtonView.isUserInteractionEnabled = false
        firstLayoutButtonView.layer.zPosition = 1
    }
    
    private func secondLayoutButtonSetting() {
        secondLayoutButtonView.contentMode = .scaleAspectFill
        secondLayoutButtonView.layer.masksToBounds = true
        secondLayoutButtonView.clipsToBounds = true
        secondLayoutButtonView.image = UIImage(named: "Layout 2")
        secondLayoutButtonView.isUserInteractionEnabled = false
        secondLayoutButtonView.layer.zPosition = 1
    }
    
    private func thirdLayoutButtonSetting() {
        thirdLayoutButtonView.contentMode = .scaleAspectFill
        thirdLayoutButtonView.layer.masksToBounds = true
        thirdLayoutButtonView.clipsToBounds = true
        thirdLayoutButtonView.image = UIImage(named: "Layout 3")
        thirdLayoutButtonView.isUserInteractionEnabled = false
        thirdLayoutButtonView.layer.zPosition = 1
    }
    
    
    // Sets the textViews font sizes according to screen size
    private func setFontSize(of textView: UITextView) {
        guard let controlerView = self.view else { return }
        if textView.font != nil {
            let size: CGFloat = controlerView.frame.width*(23.0/414.0)
            if textView === instagridTitle {
                guard let titleFont = UIFont(name: "ThirstySoftRegular", size: size) else { return }
                textView.font! = titleFont
            }
            if textView === instructionText {
                guard let instFont = UIFont(name: "Delm-Medium", size: size) else { return }
                textView.font! = instFont
            }
        }
    }
    
    
    // Create constraints according to screen size and places buttons in the first layout. Also places the corresponding views.
    private func adaptPhotosViewElementsToItsSize() {
        adaptRectangle()
        adaptRectangleView()
        adaptLeftButton()
        adaptLeftButtonView()
        adaptRightButton()
        adaptRightButtonView()
        adapttopLeftButton()
        adaptTopLeftButtonView()
        adaptTopRightButton()
        adaptTopRightButtonView()
        setPhotosViewPositionValues()
    }
    
    private func adaptRectangle() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let rectangle = viewOfPhotos.rectangle else { return }
        rectangle.translatesAutoresizingMaskIntoConstraints = false
        rectangle.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*270.0/300.0)).isActive = true
        rectangle.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        rectangle.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        rectangle.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
    }
    
    private func adaptRectangleView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let rectangleView = viewOfPhotos.rectangleView else { return }
        rectangleView.translatesAutoresizingMaskIntoConstraints = false
        rectangleView.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*270.0/300.0)).isActive = true
        rectangleView.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        rectangleView.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        rectangleView.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
    }
    
    private func adaptLeftButton() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let leftButton = viewOfPhotos.leftButton else { return }
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        leftButton.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*158.0/300.0)).isActive = true
    }
    
    private func adaptLeftButtonView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let leftButtonView = viewOfPhotos.leftButtonView else { return }
        leftButtonView.translatesAutoresizingMaskIntoConstraints = false
        leftButtonView.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        leftButtonView.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        leftButtonView.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        leftButtonView.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*158.0/300.0)).isActive = true
    }
    
    private func adaptRightButton() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let rightButton = viewOfPhotos.rightButton else { return }
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        rightButton.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*156.0/300.0)).isActive = true
        rightButton.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*158.0/300.0)).isActive = true
    }
    
    private func adaptRightButtonView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let rightButtonView = viewOfPhotos.rightButtonView else { return }
        rightButtonView.translatesAutoresizingMaskIntoConstraints = false
        rightButtonView.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        rightButtonView.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        rightButtonView.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*156.0/300.0)).isActive = true
        rightButtonView.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*158.0/300.0)).isActive = true
    }
    
    private func adapttopLeftButton() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let topLeftButton = viewOfPhotos.topLeftButton else { return }
        topLeftButton.translatesAutoresizingMaskIntoConstraints = false
        topLeftButton.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        topLeftButton.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        topLeftButton.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        topLeftButton.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        topLeftButton.alpha = 0
    }
    
    private func adaptTopLeftButtonView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let topLeftButtonView = viewOfPhotos.topLeftButtonView else { return }
        topLeftButtonView.translatesAutoresizingMaskIntoConstraints = false
        topLeftButtonView.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        topLeftButtonView.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        topLeftButtonView.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        topLeftButtonView.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
    }
    
    private func adaptTopRightButton() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let topRightButton = viewOfPhotos.topRightButton else { return }
        topRightButton.translatesAutoresizingMaskIntoConstraints = false
        topRightButton.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        topRightButton.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        topRightButton.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*156.0/300.0)).isActive = true
        topRightButton.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
        topRightButton.alpha = 0
    }
    
    private func adaptTopRightButtonView() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        guard let topRightButtonView = viewOfPhotos.topRightButtonView else { return }
        topRightButtonView.translatesAutoresizingMaskIntoConstraints = false
        topRightButtonView.widthAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.width*127.0/300.0)).isActive = true
        topRightButtonView.heightAnchor.constraint(equalToConstant: CGFloat(viewOfPhotos.frame.height*127.0/300.0)).isActive = true
        topRightButtonView.leadingAnchor.constraint(equalTo: viewOfPhotos.leadingAnchor, constant: CGFloat(viewOfPhotos.frame.height*156.0/300.0)).isActive = true
        topRightButtonView.topAnchor.constraint(equalTo: viewOfPhotos.topAnchor, constant: CGFloat(viewOfPhotos.frame.height*17.0/300.0)).isActive = true
    }
    
    private func setPhotosViewPositionValues() {
        guard let viewOfPhotos = photosViewsContainer else { return }
        let upMargin = viewOfPhotos.frame.height*17.0/300.0
        let downMargin = viewOfPhotos.frame.height*158.0/300.0
        let rightMargin = viewOfPhotos.frame.width*17.0/300.0
        
        viewOfPhotos.setPositionValues(up: upMargin, down: downMargin, right: rightMargin)
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
        guard let firstButton = firstLayoutButton else { return }
        guard let secondButton = secondLayoutButton else { return }
        guard let thirdButton = thirdLayoutButton else { return }
        firstLayoutButtonView.frame = firstButton.frame
        secondLayoutButtonView.frame = secondButton.frame
        thirdLayoutButtonView.frame = thirdButton.frame
        
        putSelectedSignOnSelectedLayoutButton()
    }
    
    private func putSelectedSignOnSelectedLayoutButton() {
        switch currentLayout {
        case .first:
            selectedSign.frame = firstLayoutButtonView.frame
        case .second:
            selectedSign.frame = secondLayoutButtonView.frame
        case .third:
            selectedSign.frame = thirdLayoutButtonView.frame
        }
    }
    
    // Sets the image selected for use in photoView
    private func photoSetting(_ photo: UIImage) {
        self.currentImageViewToFill.alpha = 1
        self.currentImageViewToFill.contentMode = .scaleAspectFill
        self.currentImageViewToFill.layer.masksToBounds = true
        self.currentImageViewToFill.clipsToBounds = true
        self.currentImageViewToFill.image = photo
    }
    
    
    // Makes the photosView's backround green if share upon release is enabled
    private func colorPhotosView() {
        if isPortrait {
            if photosViewsContainer.frame.origin.y < (viewOriginY-50) {
                photosViewsContainer.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            } else {
                photosViewsContainer.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
            }
        } else if isLandscape {
            if photosViewsContainer.frame.origin.x < (viewOriginX-50) {
                photosViewsContainer.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            } else {
                photosViewsContainer.backgroundColor = #colorLiteral(red: 0.1046529487, green: 0.3947933912, blue: 0.6130493283, alpha: 1)
            }
        }
    }

}

