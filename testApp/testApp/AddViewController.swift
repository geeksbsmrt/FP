//
//  AddViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/24/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate {
	
	let measures = ["Minutes", "Hours", "Days", "Weeks", "Months", "Years"]
	var newHunt = Hunt()
	
	let user = PFUser.currentUser()!
	
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var guessesField: UITextField!
	@IBOutlet weak var privateSwitch: UISwitch!
	@IBOutlet weak var lockLengthMeasure: UIPickerView!
	@IBOutlet weak var lockLength: UITextField!
	@IBOutlet weak var lockState: UISegmentedControl!
	
	var isPrivate: Bool = false
	
	
	@IBAction func lockControl(sender: AnyObject) {
		
		let control = sender as! UISegmentedControl
		switch control.selectedSegmentIndex {
		case 0:
			//Do nothing
			lockLength.hidden = true
			lockLengthMeasure.hidden = true
			break;
		case 1:
			//Lock Forever
			lockLength.hidden = true
			lockLengthMeasure.hidden = true
		case 2:
			//Lock For:
			lockLength.hidden = false
			lockLengthMeasure.hidden = false
		default: break;
		
		}
		
	}
	
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return measures.count
	}
	
	func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let attributedString = NSAttributedString(string: "\(measures[row])", attributes: [NSForegroundColorAttributeName : UIColor(red: 237, green: 197, blue: 181, alpha: 1)])
		return attributedString
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
		
		privateSwitch.on = isPrivate ? true : false
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if nameField.text!.utf16.count < 3 || guessesField.text!.isEmpty || (lockLength.text!.isEmpty && lockState.selectedSegmentIndex == 2){
			
			if nameField.text!.utf16.count < 3 {
				let alert = UIAlertView()
				alert.title = "Hunt Name too Short"
				alert.message = "Please choose a longer hunt name."
				alert.addButtonWithTitle("OK")
				alert.show()
			}
			
			if guessesField.text!.isEmpty {
				let alert = UIAlertView()
				alert.title = "No Guess Criteria"
				alert.message = "Please enter the number of guesses to find the endpoint."
				alert.addButtonWithTitle("OK")
				alert.show()
			}
			
			if (lockLength.text!.isEmpty && lockState.selectedSegmentIndex == 2) {
				let alert = UIAlertView()
				alert.title = "No Lock Length"
				alert.message = "Please define the length of time the hunt should lock for if users fail."
				alert.addButtonWithTitle("OK")
				alert.show()
			}
			
			return false
		}
		return true
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		newHunt.name = nameField.text!
		newHunt.createdBy = user.objectId!
		newHunt.guesses = Int(guessesField.text!)!
		newHunt.isPrivate = privateSwitch.on ? true : false
		if newHunt.isPrivate {
			newHunt.huntID = Int(arc4random_uniform(99999))
			
		}
		switch lockState.selectedSegmentIndex {
		case 1:
			newHunt.lockPermanently = true
		case 2:
			newHunt.lockPermanently = false
			switch lockLengthMeasure.selectedRowInComponent(0) {
			case 0:
				//Minutes
				newHunt.lockSeconds = Double(lockLength.text!)! * 60
			case 1:
				//Hours
				newHunt.lockSeconds = Double(lockLength.text!)! * 3600
			case 2:
				//Days
				newHunt.lockSeconds = Double(lockLength.text!)! * 86400
			case 3:
				//Weeks
				newHunt.lockSeconds = Double(lockLength.text!)! * 604800
			case 4:
				//Months
				newHunt.lockSeconds = Double(lockLength.text!)! * 2592000
			case 5:
				//Years
				newHunt.lockSeconds = Double(lockLength.text!)! * 31536000
			default:
				newHunt.lockPermanently = false
				newHunt.lockSeconds = 0
			}
		default: break
		}
		let dvc = segue.destinationViewController as! EndSelectViewController
		dvc.newHunt = newHunt
    }

}
