//
//  APIClient.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import Foundation

class APIClient {
    
    private var urlSession: URLSession {
        return URLSession.shared
    }
    
    func performRequest(endpoint: APIEndpoint, _ completionBlock:((_ result: APIResponse?, _ error: APIError?) -> Void)?) {
        guard Reachability.isConnectedToNetwork else {
            completionBlock?(nil, APIError.internetError)
            return
        }
        self.perform(endpoint: endpoint) { [weak self] (data, serverResponse, error) in
            let serverResponse = serverResponse as? HTTPURLResponse
            self?.parseResponse(data: data, response: serverResponse, error: error, { (dnResponse, apiError) in
                DispatchQueue.main.async {
                    completionBlock?(dnResponse, apiError)
                }
            })
        }
    }
    
    private func perform(endpoint: APIEndpoint, _ completionBlock:((_ data: Data?, _ response: URLResponse? , _ error: Error?) -> Void)?) {
        guard let url = URL(string: endpoint.url) else {
            completionBlock?(nil, nil, NSError(domain: "Bad Url", code: -111, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 60.0)
        request.httpMethod = endpoint.httpMethod.rawValue
//        request.allHTTPHeaderFields = [API.Headers.authorization: "Basic \(API.Headers.authKey)", API.Headers.accept: API.Headers.v3json]
        print(request)
        let task = urlSession.dataTask(with: request) {data, response, error in
            completionBlock?(data, response, error)
        }
        task.resume()
    }
    
    func parseResponse(data:Data?, response:HTTPURLResponse?, error:Error?, _ completion:((_ result: APIResponse?, _ error: APIError?) -> Void)?) {
        if let err = error {
            let error = APIError.genericError(err.localizedDescription)
            completion?(nil, error)
        } else if let rData = data {
            let dnResponse = APIResponse(data: rData)
            DispatchQueue.main.async {
                completion?(dnResponse, nil)
            }
        }
    }
}

extension APIClient: APISerializer {
    func serializeResponse<T: Codable>(_ response: APIResponse?,_ error:APIError?,_ completionBlock: ((_ result: T?, _ error: APIError?) -> Void)?) {
        self.serialize(response, error, completionBlock)
    }
}
