//
//  MobileUsageTableViewCell.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit

class MobileUsageTableViewCell: UITableViewCell {
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblUsage: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func ConfigureUI(year: String, usage: String){
        lblYear.text = year
        lblUsage.text = usage
        imgView.isHidden = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
