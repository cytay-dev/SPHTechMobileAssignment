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

/**
 Main viewcontroller to show listing of mobile data usage information in overview
 */
class ViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblOfflineContent: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - UI Controls
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Variables
    var mobileUsageData = MobileUsageData()
    
    // MARK: - Initialization
    ///Startng call to call service to begin loading data for display
    private func initStartingLoad(){
        getMobileDataUsage(numberOfItems: 1,offset: 0)
    }
    
    ///Initialize UI and control configuration for `refreshControl`
    private func initRefreshControlConfiguration(){
        refreshControl.isEnabled = true
        refreshControl.addTarget(self, action: #selector(fetchFreshData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data from Data.gov.sg")
    }
    
    ///Initialize UI and control configuration for `tableView`
    private func initTableConfiguration(){
        tableView.refreshControl = refreshControl
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 51
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.hidesWhenStopped = true
        initTableConfiguration()
        initRefreshControlConfiguration()
        initStartingLoad()
    }
    
    /**
     Fetch data from Mobile Data API client or read from cache if no network is available
        - Parameters:
            - numberOfItems: The number of item to get per request
            - offset: Number of item to skip starting from 0
     */
    private func getMobileDataUsage(numberOfItems : Int, offset: Int){
        lblOfflineContent.text = ""
        activityIndicator.startAnimating()
        refreshControl.isEnabled = true
        do{
            if try Reachability().connection == .unavailable{
                loadOfflineCache()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                return
            }
        }
        catch{
            print(error)
        }
        
        MobileDataAPIClient.shared().requestDataUsage(numberOfItems: numberOfItems, offset: offset,
                                             completion: {
                                                self.activityIndicator.stopAnimating()
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
    
    /**
     Update tableView and its relevant UIs based on its visibility state
     - Parameters:
        - showTable: Boolean flag to determine show or hide `tableView` and `btnRefresh`
        - message: Text for showing error message to inform user when negative scenarios occurs
     */
    private func toggleShowTableView(_ showTable: Bool, message: String? = ""){
        if showTable {
            self.txtLbl.text = ""
            self.btnRefresh.isHidden = true
            self.tableView.isHidden = false
        }
        else {
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = true
            self.btnRefresh.isHidden = false
            self.txtLbl.text = message
        }
    }
    
    /**
     Populate `tableView` with data retrieved either from service, mock or cache
     - Parameters:
        - response: List of raw records to received from Data.gov.sg on mobile data usage
        - fromCache: Boolean flag to determine if response is from cache or actual service call.
     - Important:when fromCache is **true**, it will determine that the current set of data need to be stored in cache for offline usage
     */
    private func populateData(response: MobileDataUsageResponse, fromCache: Bool){
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
                    self.mobileUsageData.setFilter(minYear: 2008, maxYear: 2018)
                    
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
    
    ///Load content from offline cache and update necessary UIs
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
    
    // MARK: - Action Handlers
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

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = MobileUsageTableViewHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 51))
        return view
    }
    
    
}

