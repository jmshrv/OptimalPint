//
//  SpoonsModels.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

import CoreLocation

/// The Wetherspoons API likes to return stuff in an annoying wrapper struct with just the fields
/// "success" and "data". This struct allows the API client to handle this.
struct DataWrapper<T: Codable>: Codable {
    /// The underlying data that we actually want
    let data: T

    /// Whether or not the success succeeded(?)
    let success: Bool
}

struct Venue: Codable, Hashable, Identifiable {
    static let mock: [Venue] = [
        Venue(
            id: 1,
            venueRef: 1,
            name: "The Crosse Keys",
            address: .init(
                town: "London",
                location: .init(
                    longitude: -0.084813,
                    latitude: 51.512687
                )
            )
        ),
        Venue(
            id: 2,
            venueRef: 2,
            name: "The Joseph Else",
            address: .init(
                town: "Nottingham",
                location: .init(
                    longitude: -1.149721,
                    latitude: 52.95304
                )
            )
        ),
        Venue(
            id: 3,
            venueRef: 3,
            name: "The Royal Enfield",
            address: .init(
                town: "Redditch",
                location: .init(
                    longitude: -1.943181,
                    latitude: 52.307042
                )
            )
        ),
    ]

    /// The venue address, both in human-readable words and a LatLong
    struct Address: Codable, Hashable {
        struct Location: Codable, Hashable {
            let longitude: Double
            let latitude: Double

            var cl: CLLocation {
                CLLocation(latitude: latitude, longitude: longitude)
            }
        }

        /// The town the venue is located in (yes, the JSON used the word "town")
        let town: String

        /// The coordinates of the venue
        let location: Location
    }

    /// Presumably the database ID of the venue. Hopefully unique!
    let id: Int

    /// The venue reference - used for fetching menus from this given venue
    let venueRef: Int

    /// What the venue is called
    let name: String

    /// Where the venue is
    let address: Address
}

struct FullVenue: Codable {
    let salesAreas: [SalesArea]
}

struct SalesArea: Codable, Identifiable {
    let id: Int
    let name: String
}

struct MenuLink: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let salesAreaId: Int
}

struct Menu: Codable {
    struct Category: Codable {
        struct ItemGroup: Codable {
            struct Item: Codable {
                struct Options: Codable {
                    struct Portion: Codable {
                        struct Option: Codable {
                            struct Value: Codable {
                                struct Price: Codable {
                                    let value: Double
                                }

                                let price: Price
                            }

                            let value: Value
                        }

                        let options: [Option]
                    }

                    struct Linked: Codable {
                        let name: String
                    }

                    let portion: Portion
                    let linked: [Linked]
                }

                let name: String?
                let description: String?
                let options: Options?
            }

            let name: String?
            let items: [Item]
        }

        let name: String
        let itemGroups: [ItemGroup]
    }

    let categories: [Category]
}
