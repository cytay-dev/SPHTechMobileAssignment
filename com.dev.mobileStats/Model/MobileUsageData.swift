//
//  MobileUsageData.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation

enum RecordReportFormat{
    case Year
    case Default
}

class MobileUsageData{
    
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
    
    
    private var minYearFilter = 0
    private var maxYearFilter = 0
    private var keys = [Int]()
    private var raw_records = [Record]()
    private var records_InUse: [Int:UsageData] {
        didSet{
            keys = Array(records_InUse.keys)
            keys.sort()
        }
    }
  
    private var records : [Int:UsageData] {
        didSet{
            configureRecordsForUse()
        }
    }
    
    private var format: RecordReportFormat {
        didSet{
            initRecords()
        }
    }
    
    private func OrganizeRecords(){}
    
    public var count : Int{
        get{
            return records_InUse.count
        }
    }
    
    init(){
        self.raw_records = [Record]()
        self.records = [Int:UsageData]()
        self.records_InUse = [Int:UsageData]()
        self.format = .Default
        initRecords()
    }
    
    init(_ records:[Record]){
        self.raw_records = records
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
    
    func setFilter(minYear: Int, maxYear: Int){
        minYearFilter = minYear
        maxYearFilter = maxYear
        configureRecordsForUse()
        
    }
    
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
    
    func get(_ index: Int) -> (year: Int, data: UsageData?){
        if(!records_InUse.isEmpty && index < records_InUse.count){
            let key = keys[index]
            return (key, records_InUse[key])
        }
        else{
            return (0,nil)
        }
    }
    
}
