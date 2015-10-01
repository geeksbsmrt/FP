//
//  CustomLoginView.swift
//  testApp
//
//  Created by Adam Crawford on 9/2/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class CustomLoginView: PFLogInViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.view.backgroundColor = UIColor(red:0.21, green:0.15, blue:0.15, alpha:1.0)
		
		let logoView = UIImageView(image: UIImage(named: "GeoScavengeLogo"))
		self.logInView?.logo = logoView
	}


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
