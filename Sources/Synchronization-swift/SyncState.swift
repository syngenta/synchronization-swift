//
//  SyncState.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public enum SyncState: Int, Encodable {

    /// Synchronized
    case `default`

    /// State that mark as creating (POST method)
    case create

    /// State that mark as updating (PUT method)
    case edit

    /// State that mark as deleting (DELETE method)
    case delete
}
