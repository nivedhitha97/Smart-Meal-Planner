//
//  SupermarketOffer.swift
//  SmartGroceryApp
//

import Foundation

/// A promotional line item from a weekly flyer, scoped to a region or store.
struct SupermarketOffer: Identifiable, Codable, Hashable {
    let id: UUID
    let storeName: String
    let productName: String
    let category: String
    /// Price per unit (e.g. per pack or kg — informational for planning).
    let offerPrice: Double
    let regularPrice: Double?
    let unitLabel: String
    let validUntil: Date
    let regionId: String
    let notes: String?

    var savings: Double? {
        guard let regularPrice else { return nil }
        return max(0, regularPrice - offerPrice)
    }
}
