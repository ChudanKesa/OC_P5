//
//  ViewController.swift
//  InstaGrid
//
//  Created by Erwan Le Querré on 02/05/2018.
//  Copyright © 2018 Erwan Le Querré. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Outlets & actions
    
    @IBOutlet weak var instagridTitle: UITextView!
    @IBOutlet weak var instructionText: UITextView!
    
    @IBOutlet weak var photoView: PhotosView!
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    
    @IBAction func rightButtonTouched(_ sender: UIButton) {
    }
    @IBAction func centerButtonTouched(_ sender: UIButton) {
    }
    @IBAction func leftButtonTouched(_ sender: UIButton) {
    }
    // MARK: - View life cycle
    
    // MARK: - Notifications
    
    // MARK: - UIImagePickerControllerDelegate
    
    // MARK: - Configuration

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

