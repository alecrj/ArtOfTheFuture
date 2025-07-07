//
//  Container.swift
//  ArtOfTheFuture
//
//  Dependency injection container
//

import Foundation
import SwiftUI

/// Main dependency injection container
final class Container {
    static let shared = Container()
    
    private init() {
        print("Container initialized")
    }
    
    // Services will be added here
}
