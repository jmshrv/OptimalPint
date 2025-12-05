//
//  DrinksList.swift
//  OptimalPint
//
//  Created by James Harvey on 05/12/2025.
//

import SwiftUI

struct DrinksList: View {
    private let drinks: [Drink]
    
    init(drinks: [Drink]) {
        self.drinks = drinks.sorted { $0.optimality < $1.optimality }
    }
    
    var body: some View {
        List(drinks) { drink in
            HStack {
                VStack(alignment: .leading) {
                    Text(drink.name)
                    Text("\(drink.price.formatted(.currency(code: "GBP"))), \(drink.units.formatted()) units")
                        .foregroundStyle(.secondary)
                    
                    if let dealDescription = drink.dealDescription {
                        Text(dealDescription)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                Text("\(drink.optimality.formatted(.currency(code: "GBP")))/unit")
                    .bold()
            }
        }
    }
}

#Preview {
    DrinksList(drinks: Drink.mock)
}
