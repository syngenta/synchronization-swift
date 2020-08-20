//
//  AnySyncResult.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public protocol AnySyncResult {
    var request: URLRequest { get }
    var response: URLResponse { get }
    var id: Int { get }
    var idempotencyKey: String? { get }
    var data: [String: Any?] { get }

    init(request: URLRequest, response: URLResponse, id: Int, idempotencyKey: String?, data: [String: Any?])
    static func from(data: Data, request: URLRequest, response: URLResponse) throws -> Self
}
