//
//  RecipeDetailView.swift
//  SmartGroceryApp
//

import SwiftUI

struct RecipeDetailView: View {

    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroImage

                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.title.bold())
                    Text(recipe.cuisine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                referenceLinks

                ingredientsBlock

                instructionsBlock
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let url = recipe.imageURLParsed {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(.quaternary)
                        ProgressView()
                    }
                    .frame(height: 220)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        } else {
            placeholderImage
                .padding(.horizontal)
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(.quaternary)
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var referenceLinks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("References")
                .font(.headline)
            if let yt = recipe.youtubeURLParsed {
                Link(destination: yt) {
                    Label("Watch on YouTube", systemImage: "play.rectangle.fill")
                }
                .font(.subheadline.weight(.medium))
            }
            if let bookURL = recipe.cookbookURLParsed {
                Link(destination: bookURL) {
                    Label("Cookbook / source link", systemImage: "book.fill")
                }
                .font(.subheadline.weight(.medium))
            }
            if let ref = recipe.cookbookReference, !ref.isEmpty {
                Text(ref)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            let noRefs = recipe.youtubeURL == nil && recipe.cookbookURL == nil && (recipe.cookbookReference?.isEmpty ?? true)
            if noRefs {
                Text("No external links provided for this recipe.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        .padding(.horizontal)
    }

    private var ingredientsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.title2.bold())
            ForEach(recipe.ingredients) { row in
                HStack(alignment: .firstTextBaseline) {
                    Text("•")
                    Text(row.ingredient.name)
                    Spacer()
                    Text("\(Int(row.quantity)) g")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .font(.body)
            }
        }
        .padding(.horizontal)
    }

    private var instructionsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Method")
                .font(.title2.bold())
            if recipe.instructions.isEmpty {
                Text("Add step-by-step instructions to this recipe in `recipes.json`.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)
                        Text(step)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            id: UUID(),
            name: "Sample",
            cuisine: "Demo",
            ingredients: [],
            instructions: ["Mix", "Cook", "Serve"],
            imageURL: nil,
            youtubeURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            cookbookReference: "Demo Cookbook p. 1",
            cookbookURL: "https://www.apple.com"
        ))
    }
}
