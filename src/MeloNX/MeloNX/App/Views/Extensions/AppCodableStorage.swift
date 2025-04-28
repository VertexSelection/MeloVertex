//
//  AppCodableStorage.swift
//  MeloNX
//
//  Created by Stossy11 on 12/04/2025.
//

import SwiftUI

@propertyWrapper
struct AppCodableStorage<Value: Codable & Equatable>: DynamicProperty {
    @State private var value: Value

    private let key: String
    private let defaultValue: Value
    private let storage: UserDefaults

    init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
        self._value = State(initialValue: {
            if let data = store.data(forKey: key),
               let decoded = try? JSONDecoder().decode(Value.self, from: data) {
                return decoded
            }
            return defaultValue
        }())
        self.key = key
        self.defaultValue = defaultValue
        self.storage = store
    }

    var wrappedValue: Value {
        get { value }
        nonmutating set {
            value = newValue
            if let data = try? JSONEncoder().encode(newValue) {
                storage.set(data, forKey: key)
            }
        }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in self.wrappedValue = newValue }
        )
    }
}
