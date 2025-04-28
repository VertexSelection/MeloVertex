//
//  GameRequirementsCache.swift
//  MeloNX
//
//  Created by Stossy11 on 21/03/2025.
//


import Foundation

class GameCompatibiliryCache {
    static let shared = GameCompatibiliryCache()
    private let cacheKey = "gameRequirementsCache"
    private let timestampKey = "gameRequirementsCacheTimestamp"
    
    private let cacheDuration: TimeInterval = Double.random(in: 3...5) * 24 * 60 * 60 // Randomly pick 3-5 days
    
    func getCachedData() -> [GameRequirements]? {
        guard let cachedData = UserDefaults.standard.data(forKey: cacheKey),
              let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return nil
        }

        let timeElapsed = Date().timeIntervalSince(timestamp)
        if timeElapsed > cacheDuration {
            clearCache()
            return nil
        }

        return try? JSONDecoder().decode([GameRequirements].self, from: cachedData)
    }

    func setCachedData(_ data: [GameRequirements]) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: timestampKey)
        }
    }

    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: timestampKey)
    }
}
