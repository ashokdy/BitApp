//
//  Models.swift
//  BitApp
//
//  Created by ashokdy on 03/08/2021.
//

import Foundation
import UIKit

struct Symbols: Codable {
    var symbol: String
    var dailyChange: Double
    var lastPrice: Double
    
    var price: String {
        return lastPrice.convertDoubleToCurrency()
    }
    
    var percentage: String {
        return String(format: "%.2f", dailyChange)
    }
    
    var valueColor: UIColor {
        return dailyChange < 0 ? UIColor.systemRed : UIColor.systemGreen
    }
}

struct SocketResponse: Codable, Hashable {
    var tickerChannelID: Double?
    var tradeChannelID: Double?
    var ticker: Ticker?
    var trade: [Trade]?
    init() {}
}

struct Trade: Codable, Hashable {
    var id: Double
    var mts: Double
    var amount: Double
    var price: Double
    
    var amountString: String {
        String(format: "%.4f", amount)
    }
    
    var mtsActualValue: String {
        (mts/1000).getDateStringFromUTC()
    }
}

struct Ticker: Codable, Hashable {
    var bid: Double
    var bidSize: Double
    var ask: Double
    var askSize: Double
    var dailyChange: Double
    var dailyChangeRelative: Double
    var lastPrice: Double
    var volume: Double
    var high: Double
    var low: Double
    
    var dailyChangeString: String {
        return String(format: "%.2f", dailyChange)
    }
}

struct NameValue {
    var name: String
    var value: String
}

struct NameValueDetail {
    var name: String
    var value: String
    var detail: String
}
