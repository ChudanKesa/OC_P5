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
    
    private enum Direction {
        case horizontal, vertical, undefined
    }
    private lazy var orientation = Direction.undefined
    
    private lazy var viewOriginX = CGFloat()
    private lazy var viewOriginY = CGFloat()
    
    private lazy var photosView1 = PhotosView()
    private lazy var photosView2 = PhotosView2()
    private lazy var photosView3 = PhotosView3()
    
    private enum CurrentPhotosViewInUse {
        case first, second, third
    }
    
    private lazy var currentView = CurrentPhotosViewInUse.first
    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var photosViewsContainer: UIView!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var instagridTitle: UITextView!
    @IBOutlet weak var instructionText: UITextView!
    
    @IBOutlet weak var thirdLayoutButton: UIButton!
    @IBOutlet weak var secondLayoutButton: UIButton!
    @IBOutlet weak var firstLayoutButton: UIButton!
    
    lazy var firstLayoutElementsSet = false
    lazy var secondLayoutElementsSet = false
    lazy var thirdLayoutElementSet = false
    
    @IBAction func leftButtonTouched(_ sender: UIButton) {
        removeSubviewsFromPhotosViewsContainer()
        setViewFrame(of: photosView1)
        photosViewsContainer.addSubview(photosView1)
        if !firstLayoutElementsSet {
            photosView1.setSizesAndPositionsOfElements()
            firstLayoutElementsSet = true
        }
        currentView = .first
        selectedSignSetting(button: firstLayoutButton)
    }
    
    @IBAction func centerButtonTouched(_ sender: UIButton) {
        removeSubviewsFromPhotosViewsContainer()
        setViewFrame(of: photosView2)
        photosViewsContainer.addSubview(photosView2)
        if !secondLayoutElementsSet {
            secondLayoutElementsSet = true
            photosView2.setSizesAndPositionsOfElements()
        }
        currentView = .second
        selectedSignSetting(button: secondLayoutButton)
    }

    @IBAction func rightButtonTouched(_ sender: UIButton) {
        removeSubviewsFromPhotosViewsContainer()
        setViewFrame(of: photosView3)
        photosViewsContainer.addSubview(photosView3)
        if !thirdLayoutElementSet {
            thirdLayoutElementSet = true
            photosView3.setSizesAndPositionsOfElements()
        }
        currentView = .third
        selectedSignSetting(button: thirdLayoutButton)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosViewsContainer.addGestureRecognizer(panGestureRecognizer)
        picker.delegate = self
        addNotificationObserversToViewControler()
        
        containerWidth.constant = self.view.frame.width * 300.0 / 414.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setFontSize(of: instagridTitle)
        setFontSize(of: instructionText)
        
        checkIfButtonsAreSet()
        
        setViewOriginPosition()
        
        leftButtonTouched(UIButton())
        
        hideButtons()
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
        switch currentView {
        case .first:
            currentImageViewToFill = self.photosView1.rectangleView
            associatedButton = self.photosView1.rectangle
        case .second:
            currentImageViewToFill = self.photosView2.rectangleView
            associatedButton = self.photosView2.rectangle
        default:
            break
        }
        choosePicture()
    }
    @objc
    private func putPictureInRightButton() {
        switch currentView {
        case .first:
            currentImageViewToFill = self.photosView1.rightButtonView
            associatedButton = self.photosView1.rightButton
        case .second:
            currentImageViewToFill = self.photosView2.rightButtonView
            associatedButton = self.photosView2.rightButton
        case .third:
            currentImageViewToFill = self.photosView3.rightButtonView
            associatedButton = self.photosView3.rightButton
        }
        choosePicture()
    }
    @objc
    private func putPictureInLeftButton() {
        switch currentView {
        case .first:
            currentImageViewToFill = self.photosView1.leftButtonView
            associatedButton = self.photosView1.leftButton
        case .second:
            currentImageViewToFill = self.photosView2.leftButtonView
            associatedButton = self.photosView2.leftButton
        case .third:
            currentImageViewToFill = self.photosView3.leftButtonView
            associatedButton = self.photosView3.leftButton
        }
        choosePicture()
    }
    @objc
    private func putPictureInTopRightButton() {
        switch currentView {
        case .first:
            break
        case .second:
            break
        case .third:
            currentImageViewToFill = self.photosView3.topRightButtonView
            associatedButton = self.photosView3.topRightButton
        }
        choosePicture()
    }
    @objc
    private func putPictureInTopLeftButton() {
        switch currentView {
        case .first:
            break
        case .second:
            break
        case .third:
            currentImageViewToFill = self.photosView3.topLeftButtonView
            associatedButton = self.photosView3.topLeftButton
        }
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
        setViewOriginPosition()
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
            switch currentView {
            case .first:
                photosView1.setImage(photo, for: associatedButton)
            case .second:
                photosView2.setImage(photo, for: associatedButton)
            case .third:
                photosView3.setImage(photo, for: associatedButton)
            }
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
        turnCurrentViewBlue()
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
    
    private func setViewOriginPosition() {
        viewOriginX = photosViewsContainer.frame.origin.x
        viewOriginY = photosViewsContainer.frame.origin.y
    }
    
    
    private func checkIfButtonsAreSet() {
        var alreadySet = false
        guard let viewControlerView = self.view else { return }
        let subviews = viewControlerView.subviews
        for subview in subviews.indices {
            if subviews[subview] == firstLayoutButtonView { alreadySet = true }
        }
        if !alreadySet { addLayoutButtonSubviews() }
    }
    
    private func hideButtons() {
        guard let safeFirst = firstLayoutButton else { return }
        guard let safeSecond = secondLayoutButton else { return }
        guard let safeThird = thirdLayoutButton else { return }
        
        safeFirst.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        safeSecond.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        safeThird.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        safeFirst.setTitle("", for: [])
        safeSecond.setTitle("", for: [])
        safeThird.setTitle("", for: [])
    }
    
    private func removeSubviewsFromPhotosViewsContainer() {
        guard let safeContainer = photosViewsContainer else { return }
        if safeContainer.subviews.count > 0 {
            for subview in safeContainer.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    // Sets the frame of the photosViews added to photosViewsContainer
    private func setViewFrame(of view: UIView) {
        guard let safeContainer = photosViewsContainer else { return }
        view.frame = safeContainer.frame
        view.frame.origin.x = 0
        view.frame.origin.y = 0
    }
    
    // Reccords views sizes according to screen size
    private func initSizesValues() {
        guard let controlerView = self.view else { return }

        if photosViewsContainer != nil {
            photosViewSizeSetting(accordingTo: controlerView)
        } else {
            fatalError("photosViewContainer = nil")
        }
        
        if instagridTitle != nil {
            instagridTitleSizeSetting(accordingTo: controlerView)
        } else {
            fatalError("instagridTitle = nil")
        }
        
        if instructionText != nil {
            instructionTextSizeSetting(accordingTo: controlerView)
        } else {
            fatalError("instructionText = nil")
        }
    }
    
    private func photosViewSizeSetting(accordingTo constrolerView: UIView) {
        photosViewHeight = constrolerView.frame.height*300.0/736.0
        photosViewWidth = constrolerView.frame.width*300.0/414.0
    }
    
    private func instagridTitleSizeSetting(accordingTo controlerView: UIView) {
        instagridTitleWidth = controlerView.frame.width*119.0/414.0
    }
    
    private func instructionTextSizeSetting(accordingTo controlerView: UIView) {
        instructionTextHeight = controlerView.frame.height*90.0/736.0
        instructionTextWidth = controlerView.frame.width*161.0/414.0
    }

    
    
    // Sets views sizes to reccorded values
    private func setSizes() {
        setSizeOfPhotosView()
        setSizeOfInstagridTitle()
        setSizeofInstructionText()
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
        for constraint in gridTitle.constraints {
            guard let identifier = constraint.identifier else { return }
            if identifier == "idInstaTitleWidth" {
                constraint.constant = gridTitleWidth
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
    
    
    // Puts the layout images in views on top of them. Adds the views to hierarchy, so is only to be called once.
    
    private func addLayoutButtonSubviews() {
        firstLayoutAdding()
        secondLayoutAdding()
        thirdLayoutAdding()
    }
    
        private func firstLayoutAdding() {
            firstLayoutButtonSetting()
            firstLayoutButton.addSubview(firstLayoutButtonView)
            firstLayoutButtonView.translatesAutoresizingMaskIntoConstraints = false
            firstLayoutButtonView.topAnchor.constraint(equalTo: firstLayoutButton.topAnchor, constant: 0.0).isActive = true
            firstLayoutButtonView.leftAnchor.constraint(equalTo: firstLayoutButton.leftAnchor, constant: 0.0).isActive = true
            firstLayoutButtonView.bottomAnchor.constraint(equalTo: firstLayoutButton.bottomAnchor, constant: 0.0).isActive = true
            firstLayoutButtonView.rightAnchor.constraint(equalTo: firstLayoutButton.rightAnchor, constant: 0.0).isActive = true
        }
    
        private func secondLayoutAdding() {
            secondLayoutButtonSetting()
            secondLayoutButton.addSubview(secondLayoutButtonView)
            secondLayoutButtonView.translatesAutoresizingMaskIntoConstraints = false
            secondLayoutButtonView.topAnchor.constraint(equalTo: secondLayoutButton.topAnchor, constant: 0.0).isActive = true
            secondLayoutButtonView.leftAnchor.constraint(equalTo: secondLayoutButton.leftAnchor, constant: 0.0).isActive = true
            secondLayoutButtonView.bottomAnchor.constraint(equalTo: secondLayoutButton.bottomAnchor, constant: 0.0).isActive = true
            secondLayoutButtonView.rightAnchor.constraint(equalTo: secondLayoutButton.rightAnchor, constant: 0.0).isActive = true
        }
    
        private func thirdLayoutAdding() {
            thirdLayoutButtonSetting()
            thirdLayoutButton.addSubview(thirdLayoutButtonView)
            thirdLayoutButtonView.translatesAutoresizingMaskIntoConstraints = false
            thirdLayoutButtonView.topAnchor.constraint(equalTo: thirdLayoutButton.topAnchor, constant: 0.0).isActive = true
            thirdLayoutButtonView.leftAnchor.constraint(equalTo: thirdLayoutButton.leftAnchor, constant: 0.0).isActive = true
            thirdLayoutButtonView.bottomAnchor.constraint(equalTo: thirdLayoutButton.bottomAnchor, constant: 0.0).isActive = true
            thirdLayoutButtonView.rightAnchor.constraint(equalTo: thirdLayoutButton.rightAnchor, constant: 0.0).isActive = true
        }
    
    private func selectedSignSetting(button: UIButton) {
        button.addSubview(selectedSign)
        selectedSign.translatesAutoresizingMaskIntoConstraints = false
        selectedSign.topAnchor.constraint(equalTo: button.topAnchor, constant: 0.0).isActive = true
        selectedSign.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 0.0).isActive = true
        selectedSign.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 0.0).isActive = true
        selectedSign.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 0.0).isActive = true
        selectedSign.contentMode = .scaleAspectFill
        selectedSign.layer.masksToBounds = true
        selectedSign.clipsToBounds = true
        selectedSign.image = UIImage(named: "Selected")
        selectedSign.isUserInteractionEnabled = false
        selectedSign.layer.zPosition = 2
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
    
    
    
    // Makes the photosView's backround green if share upon release is enabled
    private func colorPhotosView() {
        if isPortrait {
            if photosViewsContainer.frame.origin.y < (viewOriginY-50) {
                turnCurrentViewGreen()
            } else {
                turnCurrentViewBlue()
            }
        } else if isLandscape {
            if photosViewsContainer.frame.origin.x < (viewOriginX-50) {
                turnCurrentViewGreen()
            } else {
                turnCurrentViewBlue()
            }
        }
    }
    
    private func turnCurrentViewGreen() {
        switch currentView {
        case .first:
            photosView1.colorBackgroundGreen()
        case .second:
            photosView2.colorBackgroundGreen()
        case .third:
            photosView3.colorBackgroundGreen()
        }
    }
    
    
    private func turnCurrentViewBlue() {
        switch currentView {
        case .first:
            photosView1.colorBackgroundBlue()
        case .second:
            photosView2.colorBackgroundBlue()
        case .third:
            photosView3.colorBackgroundBlue()
        }
    }

}

