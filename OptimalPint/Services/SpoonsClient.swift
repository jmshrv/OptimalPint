//
//  SpoonsClient.swift
//  OptimalPint
//
//  Created by James Harvey on 29/11/2025.
//

import Foundation

extension URLRequest {
    static let baseUrl = URL(string: "https://ca.jdw-apps.net/api/v0.1")!
    
    static func spoons(path: String) -> URLRequest {
        var request = URLRequest(url: baseUrl.appending(path: path))
        request.setValue("Bearer 1|SFS9MMnn5deflq0BMcUTSijwSMBB4mc7NSG2rOhqb2765466", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct SpoonsClient {
    static func venues() async throws -> [Venue] {
        let request = URLRequest.spoons(path: "venues")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(DataWrapper<[Venue]>.self, from: data).data
    }
}
