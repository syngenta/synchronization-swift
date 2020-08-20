//
//  AnySyncStorage.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation
import PromiseKit

public protocol AnySyncStorage {
    func save(status: SyncStatus, error: Error?, for model: AnySynchronizable)
    func save(result: AnySyncResult, for model: AnySynchronizable) throws
    func refetch(rootModel model: AnySynchronizable) -> AnySynchronizable
}
