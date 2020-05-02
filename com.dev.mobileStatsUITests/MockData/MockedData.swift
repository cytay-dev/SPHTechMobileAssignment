//
//  MockedData.swift
//  com.dev.mobileStatsUITests
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
public final class MockedData{
    public static let response: URL = Bundle(for: MockedData.self).url(forResource: "response-mock-UI", withExtension: "json")!
    public static let responseEmpty: URL = Bundle(for: MockedData.self).url(forResource: "response-empty-mock-UI", withExtension: "json")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var string: String {
        return try! String(contentsOf: self, encoding: .utf8)
    }
}
