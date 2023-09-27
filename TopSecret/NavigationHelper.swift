//
//  NavigationHelper.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/17/22.
//  Edited by Caleb
//

import Foundation
import SwiftUI


// define env key to store our modal mode values
struct ModalModeKey: EnvironmentKey {
    static let defaultValue = Binding<Bool>.constant(false) // < required
}

// define modalMode value
extension EnvironmentValues {
    var modalMode: Binding<Bool> {
        get {
            return self[ModalModeKey.self]
        }
        set {
            self[ModalModeKey.self] = newValue
        }
    }
}
