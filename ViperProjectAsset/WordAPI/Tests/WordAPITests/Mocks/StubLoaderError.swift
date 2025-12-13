//
//  StubLoaderError.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

enum StubLoaderError: Error {
    case fileNotFound(String)
    case invalidData(String)
}
