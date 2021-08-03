//
//  APISerializer.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation

protocol APISerializer {
    func serialize<T: Codable>(_ response: APIResponse?,_ error:APIError?,_ completionBlock: ((_ result: T?, _ error: APIError?) -> Void)?)
}

extension APISerializer {
    func serialize<T: Codable>(_ response: APIResponse?,_ error:APIError?,_ completionBlock: ((_ result: T?, _ error: APIError?) -> Void)?) {
        guard let responseValue = response else {
            completionBlock?(nil, error)
            return
        }
        do {
            if let responseModel: T = try responseValue.getBitfinexModel() {
                completionBlock?(responseModel, nil)
            } else if let responseModel: T = try responseValue.getModel() {
                completionBlock?(responseModel, nil)
            } else {
                completionBlock?(nil, APIError.emptyModel)
            }
        } catch let parseError {
            completionBlock?(nil, APIError.genericError(parseError.localizedDescription))
        }
    }
}
