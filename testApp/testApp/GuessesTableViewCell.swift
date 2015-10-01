//
//  GuessesTableViewCell.swift
//  testApp
//
//  Created by Adam Crawford on 8/26/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class GuessesTableViewCell: UITableViewCell {

	@IBOutlet weak var guessNum: UILabel!
	@IBOutlet weak var guessLat: UILabel!
	@IBOutlet weak var guessLon: UILabel!
	@IBOutlet weak var distLeft: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
