//
//  File.swift
//  
//
//  Created by Evegeny Kalashnikov on 11.08.2023.
//

import Foundation

public enum SynchronizationResolveTypes {

    /// Not resolve and throw error
    case none

    /// Retry same operation
    case retry

    /// Retry same operation after delay in seconds
    case retryAfter(seconds: TimeInterval)

    /// Retry with another URLRequest
    case retryWith(request: URLRequest)

    /// Reset type will call object request from AnySynchronizable
    case reset
}
