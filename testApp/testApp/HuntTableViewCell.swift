//
//  HuntTableViewCell.swift
//  testApp
//
//  Created by Adam Crawford on 8/24/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit

class HuntTableViewCell: PFTableViewCell {


	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var dist: UILabel!
	@IBOutlet weak var guesses: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
