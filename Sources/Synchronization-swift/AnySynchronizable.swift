//
//  AnySynchronizable.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation
import PromiseKit

public protocol AnySynchronizable {

    var syncId: SyncId { get }
    var syncState: SyncState { get }
    var syncStatus: SyncStatus { get }
    var node: SyncNode { get }

    func objectRequest(settings: AnySyncSettings) throws -> URLRequest
    func syncRequest(parent: AnySyncResult?, settings: AnySyncSettings) throws -> URLRequest
}

extension AnySynchronizable {

    func isEqual(to: AnySynchronizable) -> Bool {
        self.syncId == to.syncId
    }

    func objectRequest(settings: AnySyncSettings) -> Promise<URLRequest> {
        return Promise { $0.fulfill(try self.objectRequest(settings: settings)) }
    }

    func syncRequest(parent: AnySyncResult?, settings: AnySyncSettings) -> Promise<URLRequest> {
        return Promise { $0.fulfill(try self.syncRequest(parent: parent, settings: settings)) }
    }
}
