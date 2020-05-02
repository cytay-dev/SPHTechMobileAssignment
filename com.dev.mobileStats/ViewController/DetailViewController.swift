//
//  DetailViewController.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 1/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblVolume: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var data : MobileUsageData.UsageData = MobileUsageData.UsageData(usage: 0, records: [Int : Double]())
    var year: String = ""
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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

extension DetailViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = MobileUsageTableViewHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 51))
        return view
    }
    
    
}
