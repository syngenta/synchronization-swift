//
//  SynchronizationManager.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation
import PromiseKit

public enum SynchronizationResolveTypes { // TODO: move

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

public final class SynchronizationManager<Result: AnySyncResult> {

    private let settings: AnySyncSettings
    private let storage: AnySyncStorage
    private let service: AnySyncNetworkService

    public init(settings: AnySyncSettings, storage: AnySyncStorage, service: AnySyncNetworkService) {
        self.settings = settings
        self.storage = storage
        self.service = service
    }

    private func tryToResolve(error: Error,
                              request: URLRequest,
                              node: SyncNode,
                              customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Result> {

        let type = customPerformer?.resolve(error: error, model: node.value, settings: self.settings) ?? .none
        let tryToResolve = false  // tryToResolve = false need for excluding recursive call
        switch type {
        case .none:
            return .init(error: error)
        case .retry:
            return self.perform(for: request, node: node, customPerformer: customPerformer, tryToResolve: tryToResolve)
        case .retryAfter(let seconds):
            return after(seconds: seconds).then {
                self.perform(for: request, node: node, customPerformer: customPerformer, tryToResolve: tryToResolve)
            }
        case .retryWith(let request):
            return self.perform(for: request, node: node, customPerformer: customPerformer, tryToResolve: tryToResolve)
        case .reset:
            return node.value.objectRequest(settings: self.settings).then {
                self.perform(for: $0, node: node, customPerformer: customPerformer, tryToResolve: tryToResolve)
            }
        }
    }

    private func perform(for request: URLRequest,
                      node: SyncNode,
                      customPerformer: AnySynchronizationCustomPerformer?,
                      tryToResolve: Bool = true) -> Promise<Result> {

        if let result: Promise<Result> = customPerformer?.customPerform(for: request, node: node) {
            return result
        } else {
            return self.service.perform(for: request)
                .map { try Result.from(data: $0.data, request: request, response: $0.response) }
                .recover {
                    tryToResolve ? self.tryToResolve(
                        error: $0,
                        request: request,
                        node: node,
                        customPerformer: customPerformer
                    ) : .init(error: $0)
                }
                .get { try self.storage.save(result: $0, for: node.value) } // save to db
        }
    }

    private func saveAndNotify(model: AnySynchronizable? = nil,
                               node: SyncNode,
                               status: SyncStatus,
                               error: Error? = nil,
                               listener: AnySynchronizationStatusListener?) {

        let model = model ?? node.value


        if model.syncState == .delete, status == .default { // if success deleted no object for seving status
            listener?.didUpdated(status: status, model: model, rootModel: node.root.value)
            return
        }

        listener?.didUpdated(status: status, model: model, rootModel: node.root.value)
        self.storage.save(status: status, error: error, for: node.value)
    }

    private func callAfter<Result: AnySyncResult>(after: ((AnySynchronizable, AnySyncResult) -> Promise<Void>)?,
                                              model: AnySynchronizable,
                                              result: Result) -> Promise<Result> {

        return (after?(model, result) ?? .value).map { result }
    }

    private func synchronize(node: SyncNode,
                             listener: AnySynchronizationStatusListener?,
                             customPerformer: AnySynchronizationCustomPerformer?,
                             parent: Result? = nil) -> Promise<Result> {

        let model = node.value
        let saveError = { self.saveAndNotify(node: node, status: $0, error: $1, listener: listener) }
        let save = { saveError($0, nil) }

        return model.syncRequest(parent: parent, settings: self.settings)
            .ensure(on: .main) { save(.syncing) } // send syncing
            .then { self.perform(for: $0, node: node, customPerformer: customPerformer) } // Sending request
            .tap(on: .main) { if case let .rejected(error) = $0 { saveError(.error, error) } } // send error
            .then { result -> Promise<Result> in
                let children = node.children
                    .filter { $0.value.syncState != .default } // filter already synced
                let splited = self.split(children: children) // split for separete "wait" node

                return self.byOrder(
                    all: splited,
                    listener: listener,
                    customPerformer: customPerformer,
                    parent: result
                )
                    .map { _ in result }
                    .then { self.callAfter(after: customPerformer?.afterSynchronization, model: node.value, result: $0) }
                    .then { self.callAfter(after: node.isRoot ? customPerformer?.afterAll : nil, model: node.value, result: $0) }
                    .tap(on: .main) { save($0.isFulfilled ? .default : .waiting) } // send done or waiting if some child not synced
            }
    }

    private func split(children: [SyncNode]) -> [[SyncNode]] {
        var result = [[SyncNode]]()
        var group = [SyncNode]()
        children.forEach { node in
            if node.wait {
                if group.count > 0 {
                    result.append(group)
                    group = []
                }
                result.append([node])
            } else {
                group.append(node)
            }
        }
        if group.count > 0 {
            result.append(group)
        }
        return result
    }

    private func byOrder(all: [[SyncNode]],
                         listener: AnySynchronizationStatusListener?,
                         customPerformer: AnySynchronizationCustomPerformer?,
                         result: [[Result]] = [],
                         parent: Result) -> Promise<[[Result]]> {

        guard all.count > 0 else { return .value(result) }
        guard result.count < all.count else { return .value(result) }
        let current = all[result.count]

        let promises = current.map {
            self.synchronize(
                node: $0,
                listener: listener,
                customPerformer: customPerformer,
                parent: parent
            )
        }

        return when(fulfilled: promises).then {
            self.byOrder(
                all: all,
                listener: listener,
                customPerformer: customPerformer,
                result: result + [$0],
                parent: parent
            )
        }
    }

    private func update(for node: SyncNode, listener: AnySynchronizationStatusListener?) -> Promise<Result> {

        let model = node.value
        let saveError = { self.saveAndNotify(model: model, node: node, status: $0, error: $1, listener: listener) }
        let save = { saveError($0, nil) }

        return model.objectRequest(settings: self.settings)
            .then { self.perform(for: $0, node: node, customPerformer: nil) } // Sending request
            .tap(on: .main) { // send done or error
                if case let .rejected(error) = $0 {
                    saveError(.error, error)
                } else {
                    if model.syncState == .delete {
                        save(.default) // will reset state and status to *default*
                    } else {
                        save(.waiting) // must be *waiting*, because will be syncing after reset
                    }
                }
            }
    }

    private func update(for node: SyncNode,
                        listener: AnySynchronizationStatusListener?,
                        customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Result> {

        let update: Promise<Result> = self.update(for: node, listener: listener)
        return update
            .map { _ in self.storage.refetch(rootModel: node.root.value).node }
            .then { self.synchronize(node: $0, listener: listener, customPerformer: customPerformer) }
    }
}

extension SynchronizationManager: AnySynchronizationManager {

    public func synchronize(node: SyncNode,
                            listener: AnySynchronizationStatusListener?,
                            customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Int> {

        return self.synchronize(node: node, listener: listener, customPerformer: customPerformer).map(\.id)
    }

    public func update(for node: SyncNode,
                       listener: AnySynchronizationStatusListener?,
                       customPerformer: AnySynchronizationCustomPerformer?) -> Promise<Int> {

        return self.update(for: node, listener: listener, customPerformer: customPerformer).map(\.id)
    }
}
