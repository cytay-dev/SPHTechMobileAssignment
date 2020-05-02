//
//  MobileUsageTableViewHeader.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 1/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit

///Custom View class for rendering table view header for `ViewController`
class MobileUsageTableViewHeader: UIView {
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    
    // MARK: - Initialization
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
