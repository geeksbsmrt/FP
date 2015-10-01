//
//  CustomSignUpViewController.swift
//  testApp
//
//  Created by Adam Crawford on 9/2/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class CustomSignUpViewController: PFSignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = UIColor(red:0.21, green:0.15, blue:0.15, alpha:1.0)
		
		let logoView = UIImageView(image: UIImage(named: "GeoScavengeLogo"))
		self.signUpView?.logo = logoView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
