//
//  LoginViewController.swift
//  testApp
//
//  Created by Adam Crawford on 9/2/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	
	override func viewDidAppear(animated: Bool) {
		let connected = appDelegate.connected
		
		if (connected == true) {
			if (PFUser.currentUser() == nil) { // No user logged in
				let LIVC = CustomLoginView()
				LIVC.delegate = self
				LIVC.fields = ([PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten, PFLogInFields.Facebook, PFLogInFields.Twitter])
				
				let signUpViewController = CustomSignUpViewController()
				signUpViewController.delegate = self
				
				LIVC.signUpController = signUpViewController
				
				self.presentViewController(LIVC, animated:true, completion: nil)
			} else {
				self.performSegueWithIdentifier("listSegue", sender: self)
			}
		} else {
			if(PFUser.currentUser() != nil){
				self.performSegueWithIdentifier("listSegue", sender: self)
			} else {
				//Not Connected and no current user
				let alert = UIAlertView()
				alert.title = "No Network Connection"
				alert.message = "You must have a valid network connection to login or signup"
				alert.delegate = self
				alert.addButtonWithTitle("OK")
				alert.show()
			}
		}
	}
	
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		alertView.dismissWithClickedButtonIndex(buttonIndex, animated: true)
	}

	func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
		if let username = info["username"] as? String {
			if username.utf16.count < 3 {
				let alert = UIAlertView()
				alert.title = "Error"
				alert.message = "Username must be at least 3 characters"
				alert.addButtonWithTitle("OK")
				alert.show()
				return false
			}
			if let password = info["password"] as? String {
				if password.utf16.count < 6 {
					let alert = UIAlertView()
					alert.title = "Error"
					alert.message = "Password must be at least 6 characters"
					alert.addButtonWithTitle("OK")
					alert.show()
					return false
				}
				if let email = info["email"] as? String {
					let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
					
					let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
					
					if !emailTest.evaluateWithObject(email) {
						let alert = UIAlertView()
						alert.title = "Error"
						alert.message = "Invalid Email Address"
						alert.addButtonWithTitle("OK")
						alert.show()
						return false
					}
					
					return emailTest.evaluateWithObject(email) && username.utf16.count >= 3 && password.utf16.count >= 6
				}
				return false
			}
			return false
		}
		return false
	}
	


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
		self.performSegueWithIdentifier("listSegue", sender: self)
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
		//self.performSegueWithIdentifier("listSegue", sender: self)
		PFUser.logOutInBackground()
		dismissViewControllerAnimated(true, completion: nil)
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
