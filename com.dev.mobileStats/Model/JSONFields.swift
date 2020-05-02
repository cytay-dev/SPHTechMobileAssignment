//
//  JSONFields.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation

// MARK: - MobileDataUsageResponse
struct MobileDataUsageResponse: Codable {
    let help: String?
    let success: Bool?
    let result: Result?
}

// MARK: - Result
struct Result: Codable {
    let resourceID: String?
    let fields: [Field]?
    let records: [Record]?
    let links: Links?
    let limit, total: Int?

    enum CodingKeys: String, CodingKey {
        case resourceID = "resource_id"
        case fields, records
        case links = "_links"
        case limit, total
    }
}

// MARK: - Field
struct Field: Codable {
    let type, id: String?
}

// MARK: - Links
struct Links: Codable {
    let start, next: String?
}

// MARK: - Record
struct Record: Codable {
    let volumeOfMobileData, quarter: String?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case volumeOfMobileData = "volume_of_mobile_data"
        case quarter
        case id = "_id"
    }
}

