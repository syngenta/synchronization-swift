//
//  AnySyncSettings.swift
//  Synchronization-swift
//
//  Created by Evegeny Kalashnikov on 17.06.2020.
//

import Foundation

public protocol AnySyncSettings {
    var url: URL { get }
    var token: String { get }
}
