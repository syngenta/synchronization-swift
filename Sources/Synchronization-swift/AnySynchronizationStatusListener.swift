//
//  AnySynchronizationStatusListener.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public protocol AnySynchronizationStatusListener: AnyObject {
    func didUpdated(status: SyncStatus, model: AnySynchronizable, rootModel: AnySynchronizable)
}
