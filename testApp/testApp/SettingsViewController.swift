//
//  SettingsViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/26/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIAlertViewDelegate {
	
	var user = PFUser.currentUser()!

	@IBAction func logOut(sender: AnyObject) {
		PFUser.logOutInBackground()
	}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func changeUserName(sender: AnyObject) {
		let alert = UIAlertView()
		alert.title = "Change User Name"
		alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
		let textField = alert.textFieldAtIndex(0)
		textField!.text = user.username
		alert.delegate = self
		alert.addButtonWithTitle("Cancel")
		alert.addButtonWithTitle("Change")
		alert.tag = 0
		alert.show()
	}

	@IBAction func changePassword(sender: AnyObject) {
		let alert = UIAlertView()
		alert.title = "Change Password"
		alert.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
		let textField1 = alert.textFieldAtIndex(0)
		let textField2 = alert.textFieldAtIndex(1)
		textField1?.secureTextEntry = true
		textField1?.placeholder = "New Password"
		textField2?.placeholder = "Confirm Password"
		alert.delegate = self
		alert.addButtonWithTitle("Cancel")
		alert.addButtonWithTitle("Change")
		alert.tag = 1
		alert.show()
	}
	
	@IBAction func changeEmail(sender: AnyObject) {
		let alert = UIAlertView()
		alert.title = "Change Email"
		alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
		let textField = alert.textFieldAtIndex(0)
		textField!.text = user.email
		alert.delegate = self
		alert.addButtonWithTitle("Cancel")
		alert.addButtonWithTitle("Change")
		alert.tag = 2
		alert.show()
	}
	
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if buttonIndex == 1 && (alertView.textFieldAtIndex(0)?.text != ""){
			switch alertView.tag {
				case 0:
					// Change Username
					if let newName = alertView.textFieldAtIndex(0)?.text {
						if newName != user.username && newName.utf16.count >= 3 && !newName.isEmpty {
							let query = PFUser.query()
							query?.whereKey("username", equalTo: newName)
							query?.findObjectsInBackgroundWithBlock({ (found: [PFObject]?, error: NSError?) -> Void in
								if error == nil {
									if found!.count > 0 {
										let alert = UIAlertView()
										alert.title = "Name in use"
										alert.message = "Requested name in use.  Please use a different name."
										alert.delegate = self
										alert.addButtonWithTitle("OK")
										alert.show()
									} else {
										self.user.username = newName
										self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
											if error == nil && success {
												let alert = UIAlertView()
												alert.title = "Username Changed"
												alert.message = "Your username has been changed to \(newName). Please login again."
												alert.delegate = self
												alert.addButtonWithTitle("OK")
												alert.show()
												PFUser.logOutInBackground()
												self.navigationController?.popToRootViewControllerAnimated(true)
											}
										})
									}
								} else {
									let alert = UIAlertView()
									alert.title = "Error"
									alert.message = "There was an error updating you Username.  Please try again."
									alert.delegate = self
									alert.addButtonWithTitle("OK")
									alert.show()
								}
							})
						} else {
							let alert = UIAlertView()
							alert.title = "Error"
							alert.message = "New Username cannot be the same as your current name and must be longer than 3 characters."
							alert.delegate = self
							alert.addButtonWithTitle("OK")
							alert.show()
						}
					}
				
				case 1:
					//Change password
					
					if let pw1 = alertView.textFieldAtIndex(0)!.text {
						if let pw2 = alertView.textFieldAtIndex(1)!.text {
							if pw1 == pw2 && pw1.utf16.count >= 6 {
								self.user.password = pw2
								self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
									if error == nil && success {
										let alert = UIAlertView()
										alert.title = "Password Changed"
										alert.message = "Your password has been changed. Please login again."
										alert.delegate = self
										alert.addButtonWithTitle("OK")
										alert.show()
										PFUser.logOutInBackground()
										self.navigationController?.popToRootViewControllerAnimated(true)
									} else {
										let alert = UIAlertView()
										alert.title = "Error"
										alert.message = "There was an error updating you password.  Please try again."
										alert.delegate = self
										alert.addButtonWithTitle("OK")
										alert.show()
									}
								})
							} else {
								let alert = UIAlertView()
								alert.title = "Error"
								alert.message = "New passwords do not match or must be at least 6 characters."
								alert.delegate = self
								alert.addButtonWithTitle("OK")
								alert.show()
							}
						} else {
							let alert = UIAlertView()
							alert.title = "Error"
							alert.message = "Please confirm password."
							alert.delegate = self
							alert.addButtonWithTitle("OK")
							alert.show()
						}
					} else {
						let alert = UIAlertView()
						alert.title = "Error"
						alert.message = "Password must not be blank."
						alert.delegate = self
						alert.addButtonWithTitle("OK")
						alert.show()
				}
				case 2:
					//change email
					if let newEmail = alertView.textFieldAtIndex(0)?.text {
						let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
						
						let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
						
						if !emailTest.evaluateWithObject(newEmail) {
							let alert = UIAlertView()
							alert.title = "Error"
							alert.message = "Invalid Email Address"
							alert.addButtonWithTitle("OK")
							alert.show()
						} else {
							let query = PFUser.query()
							query?.whereKey("email", equalTo: newEmail)
							query?.findObjectsInBackgroundWithBlock({ (found: [PFObject]?, error: NSError?) -> Void in
								if error == nil {
									if found!.count > 0 {
										let alert = UIAlertView()
										alert.title = "Email in use"
										alert.message = "Requested Email in use.  Please use a different Email."
										alert.delegate = self
										alert.addButtonWithTitle("OK")
										alert.show()
									} else {
										self.user.email = newEmail
										self.user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
											if error == nil && success {
												let alert = UIAlertView()
												alert.title = "Email Changed"
												alert.message = "Your email has been changed to " + newEmail
												alert.delegate = self
												alert.addButtonWithTitle("OK")
												alert.show()
											}
										})
									}
								} else {
									let alert = UIAlertView()
									alert.title = "Error"
									alert.message = "There was an error updating you email.  Please try again."
									alert.delegate = self
									alert.addButtonWithTitle("OK")
									alert.show()
								}
							})
						}
					}
				default: break
			}
		}
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
