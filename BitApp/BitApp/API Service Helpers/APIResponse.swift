//
//  APIResponse.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation

struct APIResponse {
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func getModel<T:Codable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self.data)
    }
    
    func getBitfinexModel<T: Codable>() throws -> T {
        let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[Any]]
        var jsonDictArray = [[String: Any]]()
        for tradePair in jsonArray ?? [] {
            var jsonDict = [String: Any]()
            jsonDict["symbol"] = tradePair[0] as? String
            jsonDict["dailyChange"] = tradePair[5] as? Double
            jsonDict["lastPrice"] = tradePair[7] as? Double
            jsonDictArray.append(jsonDict)
        }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictArray, options: .fragmentsAllowed)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
