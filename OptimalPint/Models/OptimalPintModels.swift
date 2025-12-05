//
//  OptimalPintModels.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

import ErrorKit
import Foundation

struct Drink: Identifiable {
    enum Error: Throwable {
        case invalidUnits(unitString: String)
        
        var userFriendlyMessage: String {
            switch self {
            case .invalidUnits(let unitString):
                String(localized: "Failed to parse Unit string \(unitString)")
            }
        }
    }
    
    /// A UUID for the object - has nothing to do with the Spoons API
    let id = UUID()
    
    /// A human readable name for the drink
    let name: String
    
    let units: Double
    
    let price: Double
    
    /// If a deal is present, the human-readable test describing the deal
    /// (for example, Any 2 for £6.40)
    let dealDescription: String?
    
    /// If a deal is present (i.e., Any 2 for £6.40), the price of one of these drinks
    let dealPrice: Double?
    
    let category: String
    
    /// If the deal price is more expensive than just buying one, returns true. Used for hiding
    /// deal text when appropriate
    var dealIsSomehowWorse: Bool {
        guard let dealPrice else { return false }
        
        return dealPrice >= price
    }
    
    var optimality: Double {        
        return (dealPrice ?? price) / units
    }
    
    init(name: String, units: Double, price: Double, dealDescription: String?, dealPrice: Double?, category: String) {
        self.name = name
        self.units = units
        self.price = price
        self.dealDescription = dealDescription
        self.dealPrice = dealPrice
        self.category = category
    }
    
    init?(from item: Menu.Category.ItemGroup.Item, category: String) throws {
        guard
            let description = item.description, let unitsString = description.firstMatch(
                of: /(\d+(?:\.\d+)?)\s*units/
            )?.output.1
        else {
            return nil
        }
   
        guard let units = Double(unitsString) else {
            throw Error.invalidUnits(unitString: String(unitsString))
        }
   
        guard
            let options = item.options, let price = options.portion.options.map({
                $0.value.price.value
            }).max()
        else {
            return nil
        }
        
        // Parse any linked deal like "Any 2 for £6.40" from the linked options' names
        let bestLinked = options.linked
            .compactMap { linked -> (String, Double)? in
                guard
                    let match = linked.name.firstMatch(
                        of: /Any (\d+) for £(\d+(?:\.\d{1,2})?)/
                    )
                else { return nil }
                
                let amountSubstring = match.output.1
                let priceSubstring = match.output.2
                
                guard let amount = Int(amountSubstring),
                    let totalPrice = Double(priceSubstring), amount > 0
                else { return nil }
                
                return (linked.name, totalPrice / Double(amount))
            }
            .min { $0.1 < $1.1 }
        
        self.init(
            name: item.name ?? "Unknown",
            units: units,
            price: price,
            dealDescription: bestLinked?.0,
            dealPrice: bestLinked?.1,
            category: category
        )
    }
    
    static let mock: [Self] = [
        .init(
            name: "Kopparberg Sweet Vintage Pear",
            units: 3.5,
            price: 3.7,
            dealDescription: "Any 2 for £6.40",
            dealPrice: 3.2,
            category: "Cider"
        )
    ]
}
