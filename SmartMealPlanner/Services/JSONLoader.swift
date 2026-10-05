//
//  JSONLoader.swift
//  SmartGroceryApp
//

import Foundation

enum JSONResourceError: Error, LocalizedError {
    case missingFile(String)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .missingFile(let name):
            return "Missing bundled JSON: \(name).json"
        case .decodingFailed(let name, let err):
            return "Could not decode \(name).json: \(err.localizedDescription)"
        }
    }
}

enum JSONLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JSONResourceError.missingFile(filename)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONResourceError.decodingFailed(filename, error)
        }
    }
}
