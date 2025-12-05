//
//  SpoonsClient.swift
//  OptimalPint
//
//  Created by James Harvey on 29/11/2025.
//

import ErrorKit
import Foundation

extension URLRequest {
    static let baseUrl = URL(string: "https://ca.jdw-apps.net/api/v0.1/jdw")!
    
    static func spoons(path: String, queryItems: [URLQueryItem] = []) -> URLRequest {
        var url = baseUrl.appending(path: path)
        url.append(queryItems: queryItems)
        
        var request = URLRequest(url: url)
        request.setValue("Bearer 1|SFS9MMnn5deflq0BMcUTSijwSMBB4mc7NSG2rOhqb2765466", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct SpoonsClient {
    static func drinks(for venue: Venue) async throws -> [Drink] {
        let request = URLRequest.spoons(path: "venues/\(venue.venueRef)")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let salesAreas = try JSONDecoder().decode(DataWrapper<[SalesArea]>.self, from: data).data
        
        let menus = try await withThrowingTaskGroup(of: [MenuLink].self) { group in
            for salesArea in salesAreas {
                group.addTask {
                    try await self.menus(for: salesArea, in: venue)
                }
            }
            
            var results: [MenuLink] = []
            for try await menu in group {
                results.append(contentsOf: menu)
            }
            return results
        }
        
        guard let drinksMenuLink = menus.first(where: { $0.name == "Drinks" }) else {
            throw SpoonsError.noDrinksMenu(foundMenus: menus)
        }
        
        let menu = try await menuDetail(for: drinksMenuLink, in: venue)
        
        return try menu.categories
            .filter { $0.name != "Includes a drink" }
            .flatMap { category in
                try category.itemGroups.flatMap {
                    try $0.items.compactMap {
                        try Drink(from: $0, category: category.name)
                    }
                }
            }
    }
    
    static func menuDetail(for menuLink: MenuLink, in venue: Venue) async throws -> Menu {
        let request = URLRequest.spoons(path: "venues/\(venue.venueRef)/sales-areas/\(menuLink.salesAreaId)/menus/\(menuLink.id)")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(DataWrapper<Menu>.self, from: data).data
    }
    
    static func menus(for salesArea: SalesArea, in venue: Venue) async throws -> [MenuLink] {
        let request = URLRequest.spoons(
            path: "venues/\(venue.venueRef)/sales-areas/\(salesArea.id)/menus",
            queryItems: [.init(
                name: "type",
                value: "available"
            )]
        )
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(DataWrapper<[MenuLink]>.self, from: data).data
    }
    
    static func venues() async throws -> [Venue] {
        let request = URLRequest.spoons(path: "venues")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(DataWrapper<[Venue]>.self, from: data).data
    }
}

enum SpoonsError: Throwable {
    case noDrinksMenu(foundMenus: [MenuLink])

   var userFriendlyMessage: String {
      switch self {
      case .noDrinksMenu(let foundMenus):
          String(localized: "Could not find a drinks menu for the selected venue. Found menus: \(ListFormatter.localizedString(byJoining: foundMenus.map(\.name)))")
      }
   }
}
