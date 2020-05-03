//
//  MobileUsageData.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation

/**
 Enum for determing how to organize the records for use in class `MobileUsageData`
 */
enum RecordReportFormat{
    case Year
    case Default
}

/**
 Data structure to hold result received from Data.gov.sg for mobile data usage information
 */
class MobileUsageData{
    // MARK: - Variables
    /**
     Data structure to hold the total volume for the year and hold additional information for how the total volume is derived and flag to determine if the year has any decrease of volume throughout the quarters
     */
    struct UsageData{
        var usage: Double
        var records: [Int:Double]{
            didSet{
                keys = Array(records.keys)
                keys.sort()
            }
        }
        
        var hasDecreaseInQuater: Bool{
            get{
                let sorted = records.sorted(by: { $0.0 < $1.0 })
                for i in 1..<sorted.count {
                    if sorted[i-1].value > sorted[i].value {
                        return true
                    }
                }
                return false
            }
        }
        
        var keys: [Int] = [Int]()
    }
    
    ///Variables for filtering the data to be used
    private var minYearFilter = 0
    private var maxYearFilter = 0
    
    ///Use for controlling the order and index of item to be returned
    private var keys = [Int]()
    ///Hold unprocessed data retrieved from rest api
    private var raw_records = [Record]()
    ///Hold filtered and processed data
    private var records_InUse: [Int:UsageData] {
        didSet{
            keys = Array(records_InUse.keys)
            keys.sort()
        }
    }
  
    ///Hold unfiltered processed data
    private var records : [Int:UsageData] {
        didSet{
            configureRecordsForUse()
        }
    }
    ///Hold the format of the data is organized in
    private var format: RecordReportFormat {
        didSet{
            initRecords()
        }
    }
    ///Return the count of the filtered and processed data
    public var count : Int{
        get{
            return records_InUse.count
        }
    }
    // MARK: - Initialization
    init(){
        self.raw_records = [Record]()
        self.records = [Int:UsageData]()
        self.records_InUse = [Int:UsageData]()
        self.format = .Default
        initRecords()
    }
    
    init(_ records:[Record], fmt: RecordReportFormat){
        self.raw_records = records
        self.records = [Int:UsageData]()
        self.records_InUse = [Int:UsageData]()
        self.format = fmt
        initRecords()
    }
    
    // MARK: - Functions
    ///Determine the range of years the records to be returned
    func setFilter(minYear: Int, maxYear: Int){
        minYearFilter = minYear
        maxYearFilter = maxYear
        configureRecordsForUse()
        
    }
    ///Get record by the index they are sorted in ascending
    func get(_ index: Int) -> (year: Int, data: UsageData?){
        if(!records_InUse.isEmpty && index < records_InUse.count){
            let key = keys[index]
            return (key, records_InUse[key])
        }
        else{
            return (0,nil)
        }
    }
    // MARK: - Private Functions
    ///Filter the processed data
    private func configureRecordsForUse(){
        if(format == .Year){
            if minYearFilter != 0 && maxYearFilter != 0{
                records_InUse = records.filter{$0.key >= minYearFilter && $0.key <= maxYearFilter}
            }
            else{
                records_InUse = records
            }
        }
        else{
            records_InUse = records
        }
    }
    
    ///Process the raw records
    private func initRecords(){
        switch format {

        case .Default, .Year:
            if !raw_records.isEmpty {
                raw_records.forEach{ rec in
                    if let quater = rec.quarter,let data = rec.volumeOfMobileData, let volume = Double(data){
                        let splitedFromQuater = quater.split(separator: "-").map { String($0) }
                        let year = Int(splitedFromQuater[0]) ?? 0
                        var quarterString = splitedFromQuater[1]
                        quarterString.removeFirst()
                        let quarter = Int(quarterString) ?? 0
                        if records.isEmpty || records[year] == nil{
                            var data = UsageData(usage: volume, records: [Int:Double]())
                            data.records[quarter] = volume
                            records[year] = data
                        }
                        else{
                            var existingUsageData = records[year]!
                            existingUsageData.usage += volume
                            existingUsageData.records[quarter] = volume
                            records[year]! = existingUsageData
                        }
                    }
                }
            }
            break;
        }
    }
    
}
