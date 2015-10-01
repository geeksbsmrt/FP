//
//  PrivateViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/23/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class PrivateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var foundHunt : Hunt!
	var currentLoc : PFGeoPoint!
	var myPrivateHunts : [Hunt]?
	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	var parseTimer = NSTimer()
	
	@IBOutlet weak var table: UITableView!
	@IBOutlet weak var tableLabel: UILabel!
	
	@IBOutlet weak var huntSearch: UITextField!
	@IBAction func unlockHuntButton(sender: AnyObject) {
		
		if huntSearch.text!.isEmpty {
			let alert = UIAlertView()
			alert.title = "Enter Search"
			alert.message = "Search field must contain a query"
			alert.addButtonWithTitle("OK")
			alert.show()
		} else {
			
			PFGeoPoint.geoPointForCurrentLocationInBackground{
				(geoPoint: PFGeoPoint?, error: NSError?) -> Void in
				if error == nil {
					// do something with the new geoPoint
					self.currentLoc = geoPoint
					if self.foundHunt != nil {
						self.performSegueWithIdentifier("priv_details", sender: nil)
					}
				}
			}
			
			var lockedHunts : [Hunt]?
			if let currentLockedHunts = PFUser.currentUser()!.objectForKey("lockedHunts") {
				lockedHunts = currentLockedHunts as? [Hunt]
			}
			
			let query = PFQuery(className: "Hunt")
			query.whereKey("huntID", equalTo: Int(huntSearch.text!)!)
			query.findObjectsInBackgroundWithBlock{
				(objects: [PFObject]?, error: NSError?) -> Void in
				
				if error == nil && objects?.count > 0 {
					if let huntObjects = objects as? [Hunt] {
						if lockedHunts == nil || !(lockedHunts!.contains(huntObjects[0])) {
							self.foundHunt = huntObjects[0]
							if self.currentLoc != nil{
								self.performSegueWithIdentifier("priv_details", sender: nil)
							}
						} else {
							let i = lockedHunts?.indexOf(huntObjects[0])
							let unlocksAt : [NSDate] = PFUser.currentUser()!.objectForKey("unlockHuntsAt") as! [NSDate]
							let thisHuntUnlocks : NSDate = unlocksAt[i!]
							let formatter = NSDateFormatter()
							formatter.dateStyle = NSDateFormatterStyle.LongStyle
							formatter.timeStyle = .MediumStyle
							let huntUnlocksAt = "This hunt will unlock at \(formatter.stringFromDate(thisHuntUnlocks))."

							let alert = UIAlertView()
							alert.title = "Locked"
							alert.message = "\(huntUnlocksAt)"
							alert.addButtonWithTitle("OK")
							alert.show()
						}
					}
				} else if error != nil {
					
				} else {
					let alert = UIAlertView()
					alert.title = "Not Found"
					alert.message = "Hunt ID not found, please try again"
					alert.addButtonWithTitle("OK")
					alert.show()
				}
				
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
		view.addGestureRecognizer(tap)
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("privateCell", forIndexPath: indexPath) as! PrivateHuntCell
		cell.nameLabel.text = myPrivateHunts![indexPath.row].name
		cell.idLabel.text = "ID: \(String(myPrivateHunts![indexPath.row].huntID))"
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.myPrivateHunts != nil {
			return self.myPrivateHunts!.count
		}
		return 0
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.Delete) {
			let deleteHunt : Hunt = myPrivateHunts![indexPath.row]
			if (appDelegate.connected!) {
				//Connected
				deleteHunt.deleteInBackgroundWithBlock({ (status: Bool, error: NSError?) -> Void in
					if error == nil && status == true {
						if self.myPrivateHunts!.count == 0 {
							self.table.hidden = true
							self.tableLabel.hidden = true
						}
					}
				})
			} else {
				//Not Connected
				deleteHunt.deleteEventually()
			}
			
			let guessQuery : PFQuery = Guess.query()!
			guessQuery.whereKey("forHunt", equalTo: deleteHunt)
			guessQuery.findObjectsInBackgroundWithBlock({ (guesses: [PFObject]?, error: NSError?) -> Void in
				if error == nil {
					PFObject.deleteAllInBackground(guesses)
				}
			})
			
			myPrivateHunts?.removeAtIndex(indexPath.row)
			table.reloadData()
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		huntSearch.text = ""
		foundHunt = nil
	}
	
	override func viewWillAppear(animated: Bool) {
		queryNetwork()
		parseTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateParse:", userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(true)
		parseTimer.invalidate()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func queryNetwork() {
		let query : PFQuery = Hunt.query()!
		query.whereKey("createdBy", equalTo: PFUser.currentUser()!.objectId!)
		query.whereKey("isPrivate", equalTo: true)
		query.findObjectsInBackgroundWithBlock { (createdHunts: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				self.myPrivateHunts	= createdHunts as? [Hunt]
				if createdHunts?.count > 0 {
					self.table.reloadData()
					self.table.hidden = false
					self.tableLabel.hidden = false
				}
			}
		}
	}
	
	func updateParse(timer: NSTimer) {
		if appDelegate.connected! {
			queryNetwork()
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "priv_details" {
			if foundHunt == nil || currentLoc == nil {
				return false
			} else {
				return true
			}
		} else {
			return true
		}
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "priv_details" {
			//huntSearch.text = ""
			let dvc = segue.destinationViewController as! HuntDetailsViewController
			dvc.selectedHunt = foundHunt
			dvc.distString = NSString(format: "%.2f miles", currentLoc.distanceInMilesTo(foundHunt.endPoint)) as String
			huntSearch.resignFirstResponder()
		}
		if segue.identifier == "priv_add" {
			let avc = segue.destinationViewController as! AddViewController
			avc.isPrivate = true
		}
	}
}
