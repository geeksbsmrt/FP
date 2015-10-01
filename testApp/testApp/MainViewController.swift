//
//  ViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/16/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController : PFQueryTableViewController {

	var currentLoc : PFGeoPoint!
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var hunts : [Hunt]!
	var parseTimer = NSTimer()
	var currentHunts : [Hunt] = []
	var currentHuntIds: [String] = []
	var lockedHunts : [Hunt] = []
	var lockedHuntIds : [String] = []
	var permLockedHunts : [Hunt] = []
	var permLockIds : [String] = []
	let user = PFUser.currentUser()!
	var currentLoaded = false
	var lockedLoaded = false
	var permLockedLoaded = false
	
	override init(style: UITableViewStyle, className: String!) {
		super.init(style: style, className: className)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Configure the PFQueryTableView
		self.parseClassName = "Hunt"
		self.pullToRefreshEnabled = true
		self.paginationEnabled = false
	}
	
	func updateParse(timer: NSTimer) {
		if appDelegate.connected! {
			self.loadObjects()
			user.fetchInBackground()
			queryNetwork()
		}
	}
	
	override func queryForTable() -> PFQuery {
		let query = PFQuery(className: "Hunt")
		
		let connected = appDelegate.connected
		
		if connected == false {
			query.fromPin()
		}
		
		query.whereKey("isPrivate", equalTo: false)
		if currentLoc != nil {
			query.whereKey("endPoint", nearGeoPoint: currentLoc, withinMiles: 100000000)
		}
		
		var filter: [String] = []
		
		if currentHuntIds.count > 0 {
			filter += currentHuntIds
		}
		
		if lockedHuntIds.count > 0 {
			filter += lockedHuntIds
		}
		
		if permLockIds.count > 0 {
			filter += permLockIds
		}
		
		if filter.count > 0 {
			query.whereKey("objectId", notContainedIn: filter)
		}

		return query
	}
	
	override func objectsDidLoad(error: NSError?) {
		super.objectsDidLoad(error)
		
		if error == nil {
			PFObject.pinAllInBackground(self.objects, block: { (success: Bool, error: NSError?) -> Void in
				if error != nil {
//					print(error?.localizedDescription)
				}
			})
		}
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if currentHunts.count > 0 {
			return 2
		}
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if currentHunts.count > 0 {
			switch section {
			case 0: return currentHunts.count
			case 1: return self.objects!.count
			default: break
			}
		}
		return self.objects!.count
	}
	
	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = UIColor.whiteColor()
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if currentHunts.count > 0 {
			switch section {
			case 0: return "Current Hunts"
			case 1: return "Public Hunts"
			default: break
			}
		}
		return "Public Hunts"
	}
	
	override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
		if let indexPath = indexPath {
			if currentHunts.count > 0 {
				switch indexPath.section {
				case 0: return self.currentHunts[indexPath.row]
				case 1: return self.objects?[indexPath.row] as? PFObject
				default: break
				}
			}
		}
		return self.objects?[indexPath!.row] as? PFObject
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
		let cell = tableView.dequeueReusableCellWithIdentifier("huntCell", forIndexPath: indexPath) as! HuntTableViewCell
		
		let hunt = object as! Hunt
		
		cell.name.text = hunt.name
		
		if currentHunts.count > 0 {
			switch indexPath.section {
			case 0:
				let query : PFQuery = Guess.query()!
				query.whereKey("forUser", equalTo: user)
				query.whereKey("forHunt", equalTo: hunt)
				
				query.findObjectsInBackgroundWithBlock { (huntGuesses: [PFObject]?, error: NSError?) -> Void in
					if error == nil && huntGuesses?.count > 0 {
						cell.guesses.text = (hunt.guesses.integerValue - huntGuesses!.count).description
					} else if error == nil {
						cell.guesses.text = hunt.guesses.description
					}
				}
				
			case 1:
				cell.guesses.text = hunt.guesses.description
			default:
				break;
			}
		} else {
			cell.guesses.text = hunt.guesses.description
		}
	
		if (currentLoc != nil){
			cell.dist.text = NSString(format: "%.2f miles", currentLoc.distanceInMilesTo(hunt.endPoint)) as String
		}
		
		return cell
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		parseTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateParse:", userInfo: nil, repeats: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		parseTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateParse:", userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		parseTimer.invalidate()
	}
	
	override func viewWillAppear(animated: Bool) {
		user.fetchInBackground()
		PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
			if error == nil {
				// do something with the new geoPoint
				self.currentLoc = geoPoint
				self.loadObjects()
			} else {
//				print(error?.localizedDescription)
			}
		}
		parseTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "updateParse:", userInfo: nil, repeats: true)
		
		queryNetwork()
	}
	
	func queryNetwork() {
		if let lockedHunts = user.objectForKey("lockedHunts") as? [Hunt] {
			if self.lockedHunts != lockedHunts {
				self.lockedHuntIds.removeAll(keepCapacity: false)
				for hunt in lockedHunts {
					self.lockedHuntIds.append(hunt.objectId!)
				}
				let query: PFQuery = Hunt.query()!
				query.whereKey("objectId", containedIn: self.lockedHuntIds)
				query.findObjectsInBackgroundWithBlock({ (retrievedObjects: [PFObject]?, error: NSError?) -> Void in
					if error == nil {
						let retrievedHunts = retrievedObjects as! [Hunt]
						if self.lockedHunts != retrievedHunts {
							self.lockedHunts = retrievedHunts
							self.lockedHuntIds.removeAll(keepCapacity: false)
							for hunt in self.lockedHunts {
								self.lockedHuntIds.append(hunt.objectId!)
							}
						}
						self.lockedLoaded = true
					}
				})
			} else {
				self.lockedLoaded = true
			}
			var locked = lockedHunts
			if let unlocksAt = user.objectForKey("unlockHuntsAt") as? [NSDate] {
				var unlocks = unlocksAt
				for unlock in unlocks {
					let now = NSDate()
					if unlock.compare(now) == NSComparisonResult.OrderedAscending || unlock.compare(now) == NSComparisonResult.OrderedSame {
						if let index = unlocksAt.indexOf(unlock) {
							locked.removeAtIndex(index)
							unlocks.removeAtIndex(index)
							user.setObject(locked, forKey: "lockedHunts")
							user.setObject(unlocks, forKey: "unlockHuntsAt")
							user.saveInBackground()
						}
					}
				}
			}
		}
		
		if let permLocked = user.objectForKey("permanentLocks") as? [Hunt] {
			
			if self.permLockedHunts != permLocked {
				self.permLockIds.removeAll(keepCapacity: false)
				for hunt in permLocked {
					self.permLockIds.append(hunt.objectId!)
				}
				let query: PFQuery = Hunt.query()!
				query.whereKey("objectId", containedIn: self.permLockIds)
				query.findObjectsInBackgroundWithBlock({ (retrievedObjects: [PFObject]?, error: NSError?) -> Void in
					if error == nil {
						let retrievedHunts = retrievedObjects as! [Hunt]
						if self.permLockedHunts != retrievedHunts {
							self.permLockedHunts = retrievedHunts
							self.permLockIds.removeAll(keepCapacity: false)
							for hunt in self.permLockedHunts {
								self.permLockIds.append(hunt.objectId!)
							}
						}
						self.permLockedLoaded = true
					}
				})
			} else {
				self.permLockedLoaded = true
			}
		}
		if let current = user.objectForKey("currentHunts") as? [Hunt] {
			
			if self.currentHunts != current {
				self.currentHuntIds.removeAll(keepCapacity: false)
				for hunt in current {
					self.currentHuntIds.append(hunt.objectId!)
					hunt.fetchIfNeededInBackground()
				}
				let query : PFQuery = Hunt.query()!
				query.whereKey("objectId", notContainedIn: lockedHuntIds)
				query.whereKey("objectId", notContainedIn: permLockIds)
				query.whereKey("objectId", containedIn: self.currentHuntIds)
				query.findObjectsInBackgroundWithBlock({ (retrievedObjects: [PFObject]?, error: NSError?) -> Void in
					if error == nil {
						let retrievedHunts = retrievedObjects as! [Hunt]
						if self.currentHunts != retrievedHunts {
							self.currentHunts = retrievedHunts
							
							//Fix for deleted private hunt?
							self.user.setObject(retrievedHunts, forKey: "currentHunts")
							self.user.saveInBackground()
							
							self.currentHuntIds.removeAll(keepCapacity: false)
							for hunt in self.currentHunts {
								self.currentHuntIds.append(hunt.objectId!)
							}
						}
						self.currentLoaded = true
					}
				})
			} else {
				self.currentLoaded = true
			}
		}
	}

	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
			
		if segue.identifier == "main_details" {
			let dvc = segue.destinationViewController as! HuntDetailsViewController
			if let indexPath = self.tableView.indexPathForSelectedRow{
				let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! HuntTableViewCell
				let sendingGuesses = Int(currentCell.guesses.text!)
				self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
				var selectedHunt: Hunt!
				if currentHunts.count > 0 {
					switch indexPath.section {
					case 0: selectedHunt = self.currentHunts[indexPath.row]
						dvc.guessesLeft = sendingGuesses
					case 1: selectedHunt = self.objects?[indexPath.row] as! Hunt
					default: break
					}
				} else {
					selectedHunt = objects![indexPath.row] as! Hunt
				}
				dvc.selectedHunt = selectedHunt
				dvc.distString = NSString(format: "%.2f miles", currentLoc.distanceInMilesTo(selectedHunt.endPoint)) as String
			}
		}
	}
}