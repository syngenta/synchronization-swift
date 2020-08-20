//
//  AnySynchronizationManager.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation
import PromiseKit

public protocol AnySynchronizationManager {
    func synchronize(node: SyncNode, listener: AnySynchronizationStatusListener?, customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Int>
    func update(for node: SyncNode, listener: AnySynchronizationStatusListener?, customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Int>
}

public extension AnySynchronizationManager { // For default parameters

    func synchronize(node: SyncNode,
                     listener: AnySynchronizationStatusListener? = nil,
                     customPerformer: AnySynchronizationCustomPerformer? = nil) -> Promise<Int> {

        return self.synchronize(node: node, listener: listener, customPerformer: customPerformer)
    }

    func update(for node: SyncNode,
                listener: AnySynchronizationStatusListener? = nil,
                customPerformer: AnySynchronizationCustomPerformer? = nil) -> Promise<Int> {

        return self.update(for: node, listener: listener, customPerformer: customPerformer)
    }
}
