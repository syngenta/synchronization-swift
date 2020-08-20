//
//  AnySyncNetworkService.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation
import PromiseKit

public protocol AnySyncNetworkService {

    /// Making request at provided URLRequest
    /// - Parameter request: URLRequest for request data
    /// - Parameter completion: complition closure with data, response or error
    func perform(for request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension AnySyncNetworkService {

    func perform(for request: URLRequest) -> Promise<(data: Data, response: URLResponse)> {
        return Promise { r in
            self.perform(for: request) { data, response, error in
                if let data = data, let response = response {
                    r.fulfill((data, response))
                } else {
                    r.reject(error ?? URLError(.unknown))
                }
            }
        }
    }
}
