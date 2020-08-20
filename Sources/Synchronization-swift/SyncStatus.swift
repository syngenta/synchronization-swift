//
//  SyncStatus.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public enum SyncStatus: Int, Encodable {

    /// Synchronized
    case `default`

    /// Waiting for synchronization (need synchronize)
    case waiting

    /// Started syncing
    case syncing

    /// Geted error while synchronize
    case error
}
