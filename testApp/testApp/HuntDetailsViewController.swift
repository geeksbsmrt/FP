//
//  HuntDetailsViewController.swift
//  testApp
//
//  Created by Adam Crawford on 8/23/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class HuntDetailsViewController: UIViewController {
	
	var selectedHunt : Hunt!
	var distString : String!
	var guessesLeft : Int?
	let user = PFUser.currentUser()!

	@IBOutlet weak var locksForLabel: UILabel!
	@IBOutlet weak var huntDist: UILabel!
	@IBOutlet weak var guesses: UILabel!
	@IBAction func startButton(sender: AnyObject) {
	}
	

	@IBOutlet weak var lockImage: UIImageView!
	
	@IBOutlet weak var startButtonLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		user.fetchIfNeededInBackground()

		navigationItem.title = selectedHunt.name
		if guessesLeft != nil {
			guesses.text = "\(guessesLeft!.description) guesses left."
//			startButtonLabel.setTitle("Continue Hunt", forState: .Normal)
		} else {
			guesses.text = "\(selectedHunt.guesses.description) guesses left."
		}
		huntDist.text = "\(distString) to the end!"
		
		if selectedHunt.lockPermanently {
			locksForLabel.text = "If you fail to find the end of this hunt within the given number of guesses, it will lock permanently and will not be able to be retried."
			let image = UIImage(named: "redLock")
			lockImage.image = image
		} else {
			var image = UIImage(named: "yellowLock")
			
			let lockLength = selectedHunt.lockSeconds.integerValue
			switch lockLength {
			case 0: locksForLabel.text = "This hunt will not lock when failed."
				image = UIImage(named: "greenLock")
			case 1..<60: locksForLabel.text = "This hunt will lock for \(lockLength) seconds when failed."
			case 60..<3600: locksForLabel.text = "This hunt will lock for \(lockLength/60) minutes when failed."
			case 3600..<86400: locksForLabel.text = "This hunt will lock for \(lockLength/3600) hours when failed."
			case 86400..<604800: locksForLabel.text = "This hunt will lock for \(lockLength/86400) days when failed."
			case 604800..<2592000: locksForLabel.text = "This hunt will lock for \(lockLength/604800) weeks when failed."
			case 2592000..<31536000: locksForLabel.text = "This hunt will lock for \(lockLength/2592000) months when failed."
			default: locksForLabel.text = "This hunt will lock for \(lockLength/31536000) years when failed."
			}
			lockImage.image = image
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		let hvc = segue.destinationViewController as! HuntViewController
		
		hvc.selectedHunt = self.selectedHunt
		
		var current: [Hunt] = []
		
		if let currentParse = user.objectForKey("currentHunts") as? [Hunt] {
			current = currentParse
			if !currentParse.contains(selectedHunt) {
				current.append(self.selectedHunt)
			}
		} else {
			current.append(self.selectedHunt)
		}
		user.setObject(current, forKey: "currentHunts")
		user.saveInBackground()
    }
}
