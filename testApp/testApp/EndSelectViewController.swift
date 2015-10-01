//
//  EndSelectViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/27/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit
import CoreLocation

class EndSelectViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
	
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var newHunt : Hunt!
	
	@IBOutlet weak var imageView: UIImageView!
	let locMan = CLLocationManager()
	var currentLoc : CLLocation!
	let coder = CLGeocoder()
	var endLoc : PFGeoPoint?

	@IBOutlet weak var toleranceDistance: UITextField!
	@IBOutlet weak var measurePicker: UIPickerView!
	@IBOutlet weak var descriptionField: UITextView!
	@IBOutlet weak var address1: UILabel!
	@IBOutlet weak var address2: UILabel!
	@IBOutlet weak var currentLocButton: UIButton!
	@IBOutlet weak var addressButton: UIButton!
	
	let measures = ["Miles", "Yards", "Feet", "Kilometers", "Meters"]
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.locMan.delegate = self
		self.locMan.desiredAccuracy = kCLLocationAccuracyBest
		self.locMan.requestWhenInUseAuthorization()
		self.locMan.startUpdatingLocation()
		
		self.navigationItem.title = newHunt.name
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
    }

	func dismissKeyboard() {
		view.endEditing(true)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	
	@IBAction func gpsLocation(sender: AnyObject) {
		
		endLoc = PFGeoPoint(location: currentLoc)
		
		coder.reverseGeocodeLocation(currentLoc) { (placeMarks: [CLPlacemark]?, error: NSError?) -> Void in
			if error != nil {
				print("Reverse geocoder failed with error" + error!.localizedDescription)
				return
			} else if placeMarks!.count > 0 {
				let place : CLPlacemark = placeMarks![0]
				print(place.name)
				self.address1.text = place.name
				self.address2.text = place.locality! + ", " + place.administrativeArea!
				self.address1.hidden = false
				self.address2.hidden = false
				//self.addressButton.hidden = true
			} else {
				print("No error, but no data")
			}

		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
			CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
				
				currentLoc = manager.location
				
		}
	}
	
	@IBAction func addressLocation(sender: AnyObject) {
		let alert = UIAlertView()
		alert.title = "Address Search"
		alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
		let textField = alert.textFieldAtIndex(0)
		textField!.placeholder = "Address, City, State"
		alert.delegate = self
		alert.addButtonWithTitle("Cancel")
		alert.addButtonWithTitle("Search")
		alert.show()
	}
	
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
	
		switch buttonIndex{
			case 0:
			//Cancel
			break
			case 1:
			//search
			let search = alertView.textFieldAtIndex(0)?.text
			coder.geocodeAddressString(search!, completionHandler: {(placeMarks, e) in
			
				if  e != nil {
					let error: NSError = e!
					print("Geocoding error: " + error.localizedDescription)
					let alert = UIAlertView()
					alert.title = "Search Failed"
					alert.message = "Please check the address and try again"
					alert.delegate = self
					alert.addButtonWithTitle("OK")
					alert.show()
				} else if placeMarks!.count > 0 {
					let place : CLPlacemark = placeMarks![0]
					self.endLoc = PFGeoPoint(location: place.location)
					print(self.currentLoc.coordinate.latitude.description + " " + self.currentLoc.coordinate.longitude.description)
					self.address1.text = place.name
					self.address2.text = place.locality! + ", " + place.administrativeArea!
					self.address1.hidden = false
					self.address2.hidden = false
					//self.currentLocButton.hidden = true
				} else {
					print("No error, but no data")
				}
			
			})
			
			default: break
		}
	}
	
	@IBAction func save(sender: AnyObject) {
		
		if endLoc == nil || imageView.image == nil || descriptionField.text.isEmpty || toleranceDistance.text!.isEmpty {
			
		} else {
			let connected = appDelegate.connected
			newHunt.endPoint = endLoc!
			newHunt.details = descriptionField.text
			newHunt.tolerance = Double(toleranceDistance.text!)!
			newHunt.toleranceMeasure = measures[measurePicker.selectedRowInComponent(0)]
			var compression : CGFloat = 0.9
			let maxCompression : CGFloat = 0.1
			let maxFileSize : Int = 104857604
			
			var imageData : NSData = UIImageJPEGRepresentation(imageView.image!, compression)!;
			
			while (imageData.length > maxFileSize && compression > maxCompression)
			{
				compression -= 0.1;
				imageData = UIImageJPEGRepresentation(imageView.image!, compression)!;
			}
			newHunt.endImage = PFFile(data: imageData)
			
			if connected == true {
				newHunt.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
					if error == nil && self.newHunt.isPrivate {
						let alert = UIAlertView()
						alert.title = "Private Hunt Created"
						alert.message = "Your Hunt ID is: " + self.newHunt.huntID.description
						alert.addButtonWithTitle("OK")
						alert.show()
					}
				})
			} else {
				newHunt.pinInBackground()
			}
			
			navigationController?.popToRootViewControllerAnimated(true)
		}
	}

	
	@IBAction func captureImage(){
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.allowsEditing = false
		
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
			imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		
		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		let tmp : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		imageView.image = tmp
		self.dismissViewControllerAnimated(true, completion: {})
		
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
    }
}
