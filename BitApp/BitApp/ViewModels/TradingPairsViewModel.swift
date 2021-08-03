//
//  TradingPairsViewModel.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation

class TradingPairsViewModel {
    
    let client = TradindPairsClient()
    
    var appsList: [Symbols]?
    
    func getAppList(_ completionBlock: (([Symbols]?, APIError?) -> Void)?) {
        client.getAppsList(request: TradingPairsAPIEndpoint()) { result, error in
            self.appsList = result
            completionBlock?(result, error)
        }
    }
}

class TradindPairsClient: APIClient {
    func getAppsList(request: TradingPairsAPIEndpoint, completionBlock: ((_ result: [Symbols]?, _ error: APIError?) -> Void)?) {
        performRequest(endpoint: request) {[weak self] (result, error) in
            self?.serializeResponse(result, error, completionBlock)
        }
    }
}
