//
//  WeeklyOffersView.swift
//  SmartGroceryApp
//

import SwiftUI

struct WeeklyOffersView: View {

    @State private var offers: [SupermarketOffer] = []
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let loadError {
                    ContentUnavailableView(
                        "Could not load offers",
                        systemImage: "exclamationmark.triangle",
                        description: Text(loadError)
                    )
                } else {
                    List {
                        Section {
                            Text("Sample weekly flyer rows — replace with scraped offers or an API feed, then keep the same `SupermarketOffer` shape.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(offers) { offer in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(offer.productName)
                                .font(.headline)
                            Text("\(offer.storeName) · \(offer.regionId)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 12) {
                                Text("€\(offer.offerPrice, format: .number.precision(.fractionLength(2)))")
                                    .fontWeight(.semibold)
                                if let regular = offer.regularPrice {
                                    Text("€\(regular, format: .number.precision(.fractionLength(2)))")
                                        .strikethrough()
                                        .foregroundStyle(.secondary)
                                }
                                Text(offer.unitLabel)
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                            Text("Until \(offer.validUntil.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Regional offers")
            .task { await loadOffers() }
        }
    }

    private func loadOffers() async {
        loadError = nil
        do {
            offers = try JSONLoader.load("offers", as: [SupermarketOffer].self)
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    WeeklyOffersView()
}
