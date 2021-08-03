//
//  APIEndPoint.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation

struct API {
    static let baseUrl = "https://api-pub.bitfinex.com/v2/tickers?symbols=ALL"
    static let subUrl = ""
    
    struct Headers {
        static let authorization = "Authorization"
        static let accept = "Accept"
        static let v3json = "application/vnd.github.v3+json"
        static let authKey = "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"
    }
}

//MARK: Headers
enum HttpMethod :String {
    case post = "POST"
    case get = "GET"
}

//MARK: Endpoint Protocol with vairables
protocol APIEndpoint {
    var baseUrl: String { get }
    var subUrl: String { get }
    var url : String { get }
}

//MARK: APIEndpoint default extension
extension APIEndpoint {
    
    var baseUrl: String {
        return API.baseUrl
    }
    
    var subUrl: String {
        return API.subUrl
    }
    
    var httpMethod: HttpMethod {
        return .get
    }
    
    var url : String {
        return baseUrl + subUrl
    }
}

struct TradingPairsAPIEndpoint: APIEndpoint {}
