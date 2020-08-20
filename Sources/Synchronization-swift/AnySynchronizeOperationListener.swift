//
//  File.swift
//  
//
//  Created by Evegeny Kalashnikov on 20.08.2020.
//

import Foundation

public protocol AnySynchronizeOperationListener: AnyObject {
    func statusDidUpdated(status: SyncStatus, model: AnySynchronizable, rootModel: AnySynchronizable)
    func didSynced(node: SyncNode, id: Int)
    func didFailed(node: SyncNode, error: Error)
}
