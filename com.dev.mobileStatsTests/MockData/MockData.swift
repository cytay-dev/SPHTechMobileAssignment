//
//  MockData.swift
//  com.dev.mobileStatsTests
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
public final class MockedData{
    public static let successWithData: URL = Bundle(for: MockedData.self).url(forResource: "response-success", withExtension: "json")!
    public static let successWithNoData: URL = Bundle(for: MockedData.self).url(forResource: "response-empty-success", withExtension: "json")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
