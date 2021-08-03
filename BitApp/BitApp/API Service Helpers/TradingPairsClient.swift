//
//  TradingPairsClient.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation
import UIKit

class TradingPairsClient: APIClient {
    func getGitReposByName(request: TradingPairsAPIEndpoint, completionBlock: ((_ result: [Symbols]?, _ error: APIError?) -> Void)?) {
        performRequest(endpoint: request) {[weak self] (result, error) in
            self?.serializeResponse(result, error, completionBlock)
        }
    }
}
