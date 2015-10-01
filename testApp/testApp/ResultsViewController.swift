//
//  ResultsViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/27/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UINavigationControllerDelegate {

	var selectedHunt : Hunt!
	var found : Bool!
	var user = PFUser.currentUser()!
	
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBAction func homeButton(sender: AnyObject) {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.setHidesBackButton(true, animated: false)

        // Do any additional setup after loading the view.
		
		if found! {
			let endImage = selectedHunt.endImage as PFFile
			endImage.getDataInBackgroundWithBlock{
				(imageData: NSData?, error: NSError?) -> Void in
				if error == nil {
					if let imageData = imageData {
						let image = UIImage(data:imageData)
						self.imageView.image = image
						self.imageView.hidden = false
					}
				}
			}
			navigationItem.title = "Success"
			detailsLabel.text = selectedHunt.details
			
			var permLocks : [Hunt] = []
			if user.objectForKey("permanentLocks")?.count > 0 {
				permLocks = user.objectForKey("permanentLocks") as! [Hunt]
			}
			permLocks.append(self.selectedHunt)
			
			var currentHunts = user.objectForKey("currentHunts") as! [Hunt]
			//var allHuntGuesses = user.objectForKey("huntGuesses") as! [[Guess]]
			if let index = currentHunts.indexOf(self.selectedHunt) {
				currentHunts.removeAtIndex(index)
				//allHuntGuesses.removeAtIndex(index)
			}
			
			let query : PFQuery = Guess.query()!
			query.whereKey("forUser", equalTo: user)
			query.whereKey("forHunt", equalTo: selectedHunt)
			
			query.findObjectsInBackgroundWithBlock { (huntGuesses: [PFObject]?, error: NSError?) -> Void in
				if error == nil && huntGuesses?.count > 0 {
					PFObject.deleteAllInBackground(huntGuesses!)
				}
			}
			
			user.setObject(permLocks, forKey: "permanentLocks")
			user.setObject(currentHunts, forKey: "currentHunts")
			user.saveInBackground()
			
		} else {
			navigationItem.title = "Failed"
			if selectedHunt.lockPermanently == false {
				if selectedHunt.lockSeconds != 0 {
					let now = NSDate()
					let unlockDate = now.dateByAddingTimeInterval(NSTimeInterval(selectedHunt.lockSeconds))
					let formatter = NSDateFormatter()
					formatter.dateStyle = NSDateFormatterStyle.LongStyle
					formatter.timeStyle = .MediumStyle
					let huntUnlocksAt = "\(formatter.stringFromDate(unlockDate))"

					detailsLabel.text = "You have failed to locate the endpoint for this hunt within the allotted number of guesses.  This hunt will unlock on \(huntUnlocksAt).\n\r Until then, you can try any other hunts available!"

					var currentLocks: [Hunt] = []
					var currentUnlocksAt: [NSDate] = []
					if user.objectForKey("lockedHunts")?.count > 0 {
						currentLocks = user.objectForKey("lockedHunts") as! [Hunt]
						if user.objectForKey("unlockHuntsAt")?.count > 0 {
							currentUnlocksAt = user.objectForKey("unlockHuntsAt") as! [NSDate]
						}
					}
					currentLocks.append(self.selectedHunt)
					currentUnlocksAt.append(unlockDate)
					
					var currentHunts = user.objectForKey("currentHunts") as! [Hunt]
					if let index = currentHunts.indexOf(self.selectedHunt) {
						currentHunts.removeAtIndex(index)
						//allHuntGuesses.removeAtIndex(index)
					}
					
					user.setObject(currentLocks, forKey: "lockedHunts")
					user.setObject(currentHunts, forKey: "currentHunts")
					user.setObject(currentUnlocksAt, forKey: "unlockHuntsAt")
					user.saveInBackground()
					
				}
			} else {
				
				detailsLabel.text = "You have failed to locate the endpoint for this hunt within the allotted number of guesses.  This hunt will lock permanently.\n\r Better luck with our other hunts!"
				
				var permLocks : [Hunt] = []
				if user.objectForKey("permanentLocks")?.count > 0 {
					permLocks = user.objectForKey("permanentLocks") as! [Hunt]
				}
				permLocks.append(self.selectedHunt)
				
				var currentHunts = user.objectForKey("currentHunts") as! [Hunt]
				//var allHuntGuesses = user.objectForKey("huntGuesses") as! [[Guess]]
				if let index = currentHunts.indexOf(self.selectedHunt) {
					currentHunts.removeAtIndex(index)
					//allHuntGuesses.removeAtIndex(index)
				}
				
				let query : PFQuery = Guess.query()!
				query.whereKey("forUser", equalTo: user)
				query.whereKey("forHunt", equalTo: selectedHunt)
				
				query.findObjectsInBackgroundWithBlock { (huntGuesses: [PFObject]?, error: NSError?) -> Void in
					if error == nil && huntGuesses?.count > 0 {
						PFObject.deleteAllInBackground(huntGuesses!)
					}
				}
				
				user.setObject(permLocks, forKey: "permanentLocks")
				user.setObject(currentHunts, forKey: "currentHunts")
				user.saveInBackground()
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(true)
		
		let query : PFQuery = Guess.query()!
		query.whereKey("forUser", equalTo: user)
		query.whereKey("forHunt", equalTo: selectedHunt)
		
		query.findObjectsInBackgroundWithBlock { (huntGuesses: [PFObject]?, error: NSError?) -> Void in
			if error == nil && huntGuesses?.count > 0 {
				PFObject.deleteAllInBackground(huntGuesses!)
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
