//
//  HuntViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/24/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit
import CoreLocation

class HuntViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

	var selectedHunt : Hunt!
	let locMan = CLLocationManager()
	let coder = CLGeocoder()
	var currentLoc : PFGeoPoint!
	var guessesLeft : NSInteger!
	var locFound = false
	var currentGuess = 0
	var guesses : [Guess] = []
	let user = PFUser.currentUser()!
	var index : Int?
	
	@IBOutlet weak var remainingGuesses: UILabel!
	
	@IBOutlet weak var guessTable: UITableView!
	
	@IBAction func guessButton(sender: AnyObject) {
		
		currentGuess++
		let thisGuess = Guess(coordinates: currentLoc, distance: currentLoc.distanceInMilesTo(selectedHunt.endPoint), number: currentGuess)
		thisGuess.forHunt = selectedHunt
		thisGuess.forUser = user
		thisGuess.saveInBackground()
		guesses.insert(thisGuess, atIndex: 0)
		
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		self.guessTable.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		guessesLeft = guessesLeft.predecessor()
		remainingGuesses.text = guessesLeft.description
		
		var tolerance : Double = selectedHunt.tolerance.doubleValue
		
		if selectedHunt.toleranceMeasure != "Miles" {
			if selectedHunt.toleranceMeasure == "Yards" {
				tolerance = tolerance / 1760
			}
			if selectedHunt.toleranceMeasure == "Feet" {
				tolerance = tolerance / 5280
			}
			if selectedHunt.toleranceMeasure == "Kilometers" {
				tolerance = tolerance / 1.60934
			}
			if selectedHunt.toleranceMeasure == "Meters" {
				tolerance = tolerance / 1609.34
			}
		}
		
		if currentLoc.distanceInMilesTo(selectedHunt.endPoint) <= tolerance {
			locFound = true
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//user.fetchInBackground()

        // Do any additional setup after loading the view.
		navigationItem.title = selectedHunt.name
		
		let query : PFQuery = Guess.query()!

		query.whereKey("forUser", equalTo: user)
		query.whereKey("forHunt", equalTo: selectedHunt)
		query.orderByDescending("createdAt")
		query.findObjectsInBackgroundWithBlock{ (huntGuesses: [PFObject]?, error: NSError?) -> Void in
			if error == nil && huntGuesses?.count > 0 {
				self.guessesLeft = self.selectedHunt.guesses.integerValue - huntGuesses!.count
				self.guesses = huntGuesses as! [Guess]
				self.currentGuess = huntGuesses!.count
				self.remainingGuesses.text = self.guessesLeft.description
				self.guessTable.reloadData()
			} else {
				self.guessesLeft = self.selectedHunt.guesses.integerValue
				self.remainingGuesses.text = self.guessesLeft.description
			}
		}
		
		self.locMan.delegate = self
		self.locMan.desiredAccuracy = kCLLocationAccuracyBest
		self.locMan.requestWhenInUseAuthorization()
		self.locMan.startUpdatingLocation()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
			CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
				
				currentLoc = PFGeoPoint(location: manager.location)
				
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return guesses.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("guessCell", forIndexPath: indexPath) as! GuessesTableViewCell
		
		let guess = guesses[indexPath.row]
		
		cell.guessLat.text = guess.coords.latitude.description
		cell.guessLon.text = guess.coords.longitude.description
		
		if guess.isDataAvailable() {
			let location : CLLocation = CLLocation(latitude: guess.coords.latitude, longitude: guess.coords.longitude)
			self.coder.reverseGeocodeLocation(location) { (placeMarks: [CLPlacemark]?, error: NSError?) -> Void in
				if error != nil {
					print("Reverse geocoder failed with error" + error!.localizedDescription)
					return
				} else if placeMarks!.count > 0 {
					let place : CLPlacemark = placeMarks![0]
					cell.guessLat.text = place.name
					cell.guessLon.text = place.locality! + ", " + place.administrativeArea!
				}
			}
			cell.guessNum.text = guess.guessNum.description
			cell.distLeft.text = NSString(format: "%.2f miles", guess.dist) as String
		} else {
			guess.fetchIfNeededInBackgroundWithBlock({ (returned: PFObject?, error: NSError?) -> Void in
				if error == nil {
					let location : CLLocation = CLLocation(latitude: guess.coords.latitude, longitude: guess.coords.longitude)
					self.coder.reverseGeocodeLocation(location) { (placeMarks: [CLPlacemark]?, error: NSError?) -> Void in
						if error != nil {
							print("Reverse geocoder failed with error" + error!.localizedDescription)
							return
						} else if placeMarks!.count > 0 {
							let place : CLPlacemark = placeMarks![0]
							cell.guessLat.text = place.name
							cell.guessLon.text = place.locality! + ", " + place.administrativeArea!
						}
					}
					cell.guessNum.text = guess.guessNum.description
					cell.distLeft.text = NSString(format: "%.2f miles", guess.dist) as String
				}
			})
		}
		return cell
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(true)

	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		let rvc = segue.destinationViewController as! ResultsViewController
		rvc.selectedHunt = self.selectedHunt
		rvc.found = locFound ? true : false
    }

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		return locFound || guessesLeft == 0 ? true : false
	}
}
