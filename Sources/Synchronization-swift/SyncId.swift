//
//  SyncId.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public enum SyncId: Equatable, Hashable {

    /// Real id
    case id(_ id: Int)

    /// This is local id (idempotency key)
    case localId(_ id: String)

    public static func generateLocalId() -> SyncId {
        return .localId(self.generateUUID())
    }

    public static func generateUUID() -> String {
        return UUID().uuidString + "-\(Date().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "-")
    }
}


extension SyncId: Encodable {

    private enum Keys: String, CodingKey {
        case id
        case localId = "local_id"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case .id(let id):
            try container.encode(id, forKey: .id)
        case .localId(let id):
            try container.encode(id, forKey: .localId)
        }
    }
}
