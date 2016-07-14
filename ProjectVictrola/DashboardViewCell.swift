//
//  DashboardViewCell.swift
//  Glyf
//
//  Created by Philip Chacko on 11/3/15.
//  Copyright © 2015 Phil Chacko. All rights reserved.
//

import UIKit

class DashboardViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPostTitle: UITextView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPostedBy: UILabel!
    @IBOutlet weak var imgPlaceIcon: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!

    var imageName: String!
    var heartedByUser = false
    var viewedByUser = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
