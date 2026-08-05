//
//  MCatalog+Language.swift
//  MusadoraKit
//
//  Created by Claude on 05/08/26.
//

import Foundation

/// `LanguageTagResponse` is a struct that decodes the response from the best supported language endpoint.
///
/// This structure corresponds to the response you would receive when asking the Apple Music API
/// for the best supported language tag of a storefront.
///
/// - Note: Apple's documentation refers to this object as `LangageTagResponse` (sic);
///         MusadoraKit spells it correctly.
struct LanguageTagResponse: Decodable {
  /// The results container returned by the endpoint.
  let results: Results

  /// The container holding the resolved language tag.
  struct Results: Decodable {
    /// The best language tag supported by the storefront, as an RFC 4646 language tag.
    let tag: String
  }
}

public extension MCatalog {
  /// Fetches the best supported language tag for a storefront of Apple Music.
  ///
  /// Pass the language tags your app accepts, in order of preference, and the Apple Music API
  /// resolves them against the storefront's supported language tags server-side. The returned
  /// tag is the best match, ready to use as the localization (`l`) parameter in subsequent
  /// catalog requests.
  ///
  /// Example usage:
  ///
  /// ```swift
  /// do {
  ///     let languageTag = try await MCatalog.bestLanguageTag(for: "in", accepting: ["hi", "en-GB"])
  ///     print(languageTag) // "hi"
  /// } catch {
  ///     print("Failed to fetch the best language tag: \(error)")
  /// }
  /// ```
  ///
  /// In the above example, "in" is the identifier for the India storefront, and the accepted
  /// languages prefer Hindi over British English.
  ///
  /// - Parameters:
  ///   - storefront: The identifier for the storefront you want to resolve the language for. This is usually a country code.
  ///   - languages: The language tags your app accepts, in order of preference.
  ///   - localization: An optional localization to use for the request. Defaults to `nil`.
  /// - Returns: The best language tag supported by the storefront, as an RFC 4646 language tag.
  /// - Throws: `MusadoraKitError.languageTagsMissing` if `languages` is empty, or an error if there was a problem with the network request or decoding the response.
  static func bestLanguageTag(for storefront: String, accepting languages: [String], localization: String? = nil) async throws -> String {
    let url = try bestLanguageTagURL(storefront: storefront, languages: languages, localization: localization)

    let request = MusicDataRequest(urlRequest: .init(url: url))
    let response = try await request.response()
    let languageTag = try JSONDecoder().decode(LanguageTagResponse.self, from: response.data)

    return languageTag.results.tag
  }

  /// Fetches the best supported language tag for a storefront of Apple Music,
  /// based on the user's preferred languages.
  ///
  /// This convenience method uses `Locale.preferredLanguages` — the user's preferred
  /// languages, in order — as the accepted language tags.
  ///
  /// Example usage:
  ///
  /// ```swift
  /// do {
  ///     let languageTag = try await MCatalog.bestLanguageTag(for: "in")
  ///     print(languageTag)
  /// } catch {
  ///     print("Failed to fetch the best language tag: \(error)")
  /// }
  /// ```
  ///
  /// - Parameter storefront: The identifier for the storefront you want to resolve the language for. This is usually a country code.
  /// - Returns: The best language tag supported by the storefront, as an RFC 4646 language tag.
  /// - Throws: `MusadoraKitError.languageTagsMissing` if `Locale.preferredLanguages` is empty, or an error if there was a problem with the network request or decoding the response.
  static func bestLanguageTag(for storefront: String) async throws -> String {
    try await bestLanguageTag(for: storefront, accepting: Locale.preferredLanguages)
  }
}

extension MCatalog {
  /// Returns the URL for fetching the best supported language tag for the specified storefront.
  ///
  /// - Parameters:
  ///   - storefront: The identifier for the storefront.
  ///   - languages: The language tags to accept, in order of preference.
  ///   - localization: An optional localization to use for the request.
  ///
  /// - Returns: The URL for fetching the best supported language tag for the specified storefront.
  internal static func bestLanguageTagURL(storefront: String, languages: [String], localization: String?) throws -> URL {
    guard !languages.isEmpty else {
      throw MusadoraKitError.languageTagsMissing
    }

    var urlComponents = AppleMusicURLComponents()
    urlComponents.path = "language/\(storefront)/tag"

    var queryItems = [URLQueryItem(name: "acceptLanguage", value: languages.joined(separator: ","))]

    if let localization, !localization.isEmpty {
      queryItems.append(URLQueryItem(name: "l", value: localization))
    }

    urlComponents.queryItems = queryItems

    guard let url = urlComponents.url else {
      throw URLError(.badURL)
    }

    return url
  }
}
