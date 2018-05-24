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

    @IBOutlet var mainView: UIView!
}
