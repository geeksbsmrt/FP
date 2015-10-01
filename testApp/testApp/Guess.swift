//
//  Guess.swift
//  testApp
//
//  Created by Adam Crawford on 8/26/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit
import CoreLocation

class Guess: PFObject, PFSubclassing {

	static func parseClassName() -> String {
		return "Guess"
	}
		
	@NSManaged var coords : PFGeoPoint
	@NSManaged var dist : CLLocationDistance
	@NSManaged var guessNum : NSInteger
	@NSManaged var forHunt : Hunt
	@NSManaged var forUser : PFUser
	
	init(coordinates: PFGeoPoint, distance: CLLocationDistance, number: NSInteger){
		super.init()
		self.coords = coordinates
		self.dist = distance
		self.guessNum = number
	}
	
	override init() {
		super.init()
	}
	
}
