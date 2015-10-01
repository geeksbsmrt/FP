//
//  Hunt.swift
//  testApp
//
//  Created by Adam Crawford on 8/23/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

func createID() -> Int {
	return random()
}

class Hunt: PFObject, PFSubclassing {
	
	@NSManaged var name : String
	@NSManaged var huntID : Int
	@NSManaged var guesses : NSNumber
	@NSManaged var endPoints : [EndPoint]
	@NSManaged var endPoint : PFGeoPoint
	@NSManaged var endImage : PFFile
	@NSManaged var details : String
	@NSManaged var isPrivate : Bool
	@NSManaged var tolerance : NSNumber
	@NSManaged var toleranceMeasure : String
	@NSManaged var lockPermanently : Bool
	@NSManaged var lockSeconds : NSNumber
	@NSManaged var createdBy : String
	
	static func parseClassName() -> String {
		return "Hunt"
	}
	
	override init() {
		super.init()
	}
	
	override class func query() -> PFQuery? {
		let query = PFQuery(className: Hunt.parseClassName())
		return query
	}

}
