//
//  ViewController.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import UIKit
import Alamofire
import Reachability

class ViewController: UIViewController {
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblOfflineContent: UILabel!
    
    private let refreshControl = UIRefreshControl()
    
    var mobileUsageData = MobileUsageData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initTableConfiguration()
        initRefreshControlConfiguration()
        initStartingLoad()
    }
    
    private func initStartingLoad(){
        getMobileDataUsage(numberOfItems: 1,offset: 0)
    }
    
    private func initRefreshControlConfiguration(){
        refreshControl.isEnabled = true
        refreshControl.addTarget(self, action: #selector(fetchFreshData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data from Data.gov.sg")
    }
    
    private func initTableConfiguration(){
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 51
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    private func getMobileDataUsage(numberOfItems : Int, offset: Int){
        lblOfflineContent.text = ""
        refreshControl.isEnabled = true
        do{
            if try Reachability().connection == .unavailable{
                loadOfflineCache()
                self.refreshControl.endRefreshing()
                return
            }
        }
        catch{
            print(error)
        }
        
        MobileDataAPIClient.requestDataUsage(numberOfItems: numberOfItems, offset: offset,
                                             completion: {
            self.refreshControl.endRefreshing()
        },
                                             success: { (response) in
                                                self.populateData(response: response, fromCache: false)
        },
                                             fail: { (err) in
                                                if let afError = err.asAFError {
                                                    switch afError {
                                                        case .sessionTaskFailed(let sessionError):
                                                            if let urlError = sessionError as? URLError {
                                                                switch urlError.code{
                                                                    case .notConnectedToInternet:
                                                                        self.loadOfflineCache()
                                                                        break;
                                                                    case .timedOut:
                                                                        self.toggleShowTableView(false, message: "Request has timed out. Please try again")
                                                                        break;
                                                                    default:
                                                                        self.toggleShowTableView(false, message: "Error occured. Error = \(urlError.localizedDescription)")
                                                                }
                                                        }
                                                        default:
                                                            self.toggleShowTableView(false, message: "Something went wrong. Please try again.")
                                                    }
                                                }
        })
       
    }
    
    private func toggleShowTableView(_ showTable: Bool, message: String? = ""){
        if(showTable){
            self.txtLbl.text = ""
            self.btnRefresh.isHidden = true
            self.tableView.isHidden = false
        }
        else{
            self.tableView.isHidden = true
            self.btnRefresh.isHidden = false
            self.txtLbl.text = message
        }
    }
    
    private func populateData(response:MobileDataUsageResponse, fromCache: Bool){
        var success = false
        self.txtLbl.text = ""
        if let responseSuccess = response.success{
            success = responseSuccess
        }
        if success {
            toggleShowTableView(true)
            var limit = 0, max = 0
            if let result = response.result, let resultLimit = result.limit, let resultMax = result.total{
                limit = resultLimit
                max = resultMax
            }
            
            if max == 0{
                toggleShowTableView(false, message: "No Mobile Usage data is available")
            }
            else if limit < max{
                self.getMobileDataUsage(numberOfItems: max, offset: 0)
            }
            else{
                self.btnRefresh.isHidden = true
                if let result = response.result, let records = result.records{
                    
                    self.mobileUsageData = MobileUsageData(records, fmt: .Year)
                    self.mobileUsageData.setFilter(minYear: 2008, maxYear: 2019)
                    
                    self.tableView.reloadData()
                    DispatchQueue.global(qos: .utility).async {
                        if !fromCache {
                            OfflineCacheManager.shared().saveJSON(array: response)
                        }
                    }
                }
            }
        }
        else{
            toggleShowTableView(false, message: "Error retrieving data from Data.gov.sg")
        }
        
    }
    
    private func loadOfflineCache(){
        if let record = OfflineCacheManager.shared().readJSON(MobileDataUsageResponse.self){
            toggleShowTableView(true)
            populateData(response: record, fromCache: true)
            refreshControl.isEnabled = false
            lblOfflineContent.text = "Using offline content"
        }
        else{
            toggleShowTableView(false, message: "Internet is unavailable")
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imgView = tapGestureRecognizer.view as! UIImageView
        performSegue(withIdentifier: "DisplayDetail", sender: imgView.tag)
    }
    
    @objc private func fetchFreshData(_ sender: Any) {
        getMobileDataUsage(numberOfItems: 1,offset: 0)
    }
    
    @IBAction func refreshData(_ sender: Any) {
        getMobileDataUsage(numberOfItems: 1,offset: 0)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DisplayDetail"{
            if let nextViewController = segue.destination as? DetailViewController, let index = sender as? Int{
                let info = mobileUsageData.get(index)
                let yearString = String(info.year)
                nextViewController.title = yearString
                if let data = info.data{
                    nextViewController.data = data
                    nextViewController.year = yearString
                }
            }
        }
    }
    
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileUsageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! MobileUsageTableViewCell
        let info = mobileUsageData.get(indexPath.row)
        var usage: Double = 0
        var dontShowImg = true
        if let data = info.data{
            usage = data.usage
            dontShowImg = !data.hasDecreaseInQuater
        }
        cell.ConfigureUI(year: String(info.year), usage: String(usage))
        cell.imgView.tag = indexPath.row
        cell.imgView.isHidden = dontShowImg
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.imgView.isUserInteractionEnabled = true
        cell.imgView.addGestureRecognizer(tapGestureRecognizer)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = MobileUsageTableViewHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 51))
        return view
    }
    
    
}

