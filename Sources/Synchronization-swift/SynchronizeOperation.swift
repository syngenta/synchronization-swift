//
//  SynchronizeOperation.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 07.08.2020.
//

import Foundation

public class SynchronizeOperation: Operation, AnySynchronizationStatusListener {

    private let node: SyncNode
    private let manager: AnySynchronizationManager
    private weak var listener: AnySynchronizeOperationListener?
    private weak var customPerformer: AnySynchronizationCustomPerformer?

    public func isEqual(to identifier: SyncId) -> Bool {
        return self.node.value.syncId == identifier
    }

    public func isEqual(to node: SyncNode) -> Bool {
        return self.node == node
    }

    public init(node: SyncNode,
                manager: AnySynchronizationManager,
                listener: AnySynchronizeOperationListener,
                customPerformer: AnySynchronizationCustomPerformer? = nil) {

        self.node = node
        self.manager = manager
        self.listener = listener
        self.customPerformer = customPerformer
    }

    public override func main() {
        super.main()
        do {
            let rootId = try self.manager
                .synchronize(node: self.node, listener: self, customPerformer: self.customPerformer)
                .wait()

            self.listener?.didSynced(node: self.node, id: rootId)
        } catch {
            self.listener?.didFailed(node: self.node, error: error)
        }
    }

    public func didUpdated(status: SyncStatus, model: AnySynchronizable, rootModel: AnySynchronizable) {
        self.listener?.statusDidUpdated(status: status, model: model, rootModel: rootModel)
    }
}
