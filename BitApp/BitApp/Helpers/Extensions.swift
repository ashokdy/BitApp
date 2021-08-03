//
//  Extensions.swift
//  KryptoChallenge
//
//  Created by   on 25/07/2021.
//

import Foundation

extension Double {
    func convertDoubleToCurrency(format: String = "en_US") -> String {
        let amount = self
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: format) // Can be custom
        return numberFormatter.string(from: NSNumber(value: amount)) ?? ""
    }
}

extension Double {
    func getDateStringFromUTC(format: String = "en_US") -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.locale = Locale(identifier: format)
        
        return dateFormatter.string(from: date)
    }
    
    func with2Fractions() -> String {
        String(format: "%.2f", self)
    }
}
