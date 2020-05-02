//
//  MobileUsageTableViewHeader.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 1/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit

class MobileUsageTableViewHeader: UIView {

    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("MobileUsageTableViewHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
