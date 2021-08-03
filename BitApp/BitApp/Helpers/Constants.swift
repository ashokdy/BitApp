//
//  Constants.swift
//  KryptoChallenge
//
//  Created by   on 25/07/2021.
//

import Foundation

let webSocketURL = "wss://api-pub.bitfinex.com/ws/2"

enum Section: String {
    case main
}

enum Cell: String {
    case stock = "Stock"
}

enum KryptoStock: String {
    case subscribe
    case unsubscribe
}

struct KryptoError {
    static let networkError = "Please check your Internet Connection, Once you are online it will auto refresh the Krypto stocks"
}

