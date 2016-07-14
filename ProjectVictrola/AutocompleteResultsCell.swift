//
//  AutocompleteResultsCell.swift
//  Glyf
//
//  Created by Philip Chacko on 8/31/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit

class AutocompleteResultsCell: UITableViewCell {

    @IBOutlet weak var labelPlaceTitle: UILabel!
    @IBOutlet weak var labelPlaceDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
