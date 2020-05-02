//
//  DetailViewController.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 1/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit

/**
 ViewController to show breakdown information of yearly mobile data usage information
 */
class DetailViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblVolume: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var data : MobileUsageData.UsageData = MobileUsageData.UsageData(usage: 0, records: [Int : Double]())
    var year: String = ""
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 51
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension DetailViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! MobileUsageTableViewCell
        let key = data.keys[indexPath.row]
        var usage = ""
        if let recordedUsage = data.records[key]{
            usage = String(recordedUsage)
        }
        cell.ConfigureUI(year: "\(year)-Q\(key)", usage: usage)
        cell.imgView.isHidden = true
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = MobileUsageTableViewHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 51))
        return view
    }
    
    
}
