//
//  DrinksList.swift
//  OptimalPint
//
//  Created by James Harvey on 05/12/2025.
//

import SwiftUI

struct DrinksList: View {
    private let drinks: [Drink]

    @State private var searchTerm = ""

    init(drinks: [Drink]) {
        self.drinks = drinks.sorted { $0.optimality < $1.optimality }
    }

    var body: some View {
        List(listContent) { drink in
            HStack {
                VStack(alignment: .leading) {
                    Text(drink.name)
                    Text("\(drink.units.formatted()) units")
                        .foregroundStyle(.secondary)

                    if let dealDescription = drink.dealDescription {
                        Text(dealDescription)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(
                        "\(drink.optimality.formatted(.currency(code: "GBP")))/unit"
                    )
                    .bold()
                    Text("\(drink.price.formatted(.currency(code: "GBP")))")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .searchable(text: $searchTerm)
    }

    private var listContent: [Drink] {
        if searchTerm.isEmpty {
            return drinks
        }

        let trimmedSearchTerm = searchTerm.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return
            drinks
            .filter {
                $0.name.localizedStandardContains(trimmedSearchTerm)
            }
            .sorted { $0.name < $1.name }
    }
}

#Preview {
    DrinksList(drinks: Drink.mock)
}
