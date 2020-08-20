//
//  SyncNode.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

final public class SyncNode: Equatable {

    public let value: AnySynchronizable
    public let wait: Bool
    public private(set) var parent: SyncNode?
    public let children: [SyncNode]
    public let size: Int

    private var _index: String?
    public var index: String {
        let index = self._index ?? self.getIndex()
        self._index = index
        return index
    }

    private func getIndex() -> String {
        guard let parent = self.parent else { return "0" }
        let index = parent.children.firstIndex(of: self)
        return parent.getIndex() + "/" + (index.flatMap { String($0) } ?? "nan")
    }

    public func at(_ index: String) -> SyncNode? {
        let indexes = index.components(separatedBy: "/").map {
            Int($0) ?? .max
        }
        guard !indexes.contains(.min) else { return nil }
        guard indexes.count > 1 else { return self }
        let index = indexes[1]
        guard index < self.children.count else { return nil }
        let nextIndex = indexes.dropFirst().map { String($0) }.joined(separator: "/")
        return self.children[index].at(nextIndex)
    }

    public var isRoot: Bool {
        self.parent == nil
    }

    public var isLast: Bool {
        self.size == 1
    }

    public var root: SyncNode {
        guard let parent = self.parent else { return self }
        return parent.root
    }

    public var flatChildren: [SyncNode] {
        self.children.reduce(into: [], { $0 += $1.flat })
    }

    public var flat: [SyncNode] {
        [self] + self.flatChildren
    }

    public init<T: AnySynchronizable>(_ value: T, wait: Bool = false, children: ((T) -> [SyncNode])? = nil) {
        self.value = value
        self.wait = wait
        self.children = children?(value) ?? []
        self.size = self.children.reduce(into: 1, { $0 += $1.size })
        self.children.forEach { $0.parent = self }
    }

    public static func == (lhs: SyncNode, rhs: SyncNode) -> Bool {
        lhs.value.isEqual(to: rhs.value)
    }
}
