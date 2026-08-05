//
//  LanguageTagEndpointTests.swift
//  MusadoraKitTests
//
//  Created by Claude on 05/08/26.
//

import Foundation
@testable import MusadoraKit
import Testing

@Suite
struct LanguageTagEndpointTests {
  @Test
  func bestLanguageTagEndpointForStorefront() throws {
    let url = try MCatalog.bestLanguageTagURL(storefront: "in", languages: ["hi", "en-GB"], localization: nil)
    expectEndpoint(url, equals: "https://api.music.apple.com/v1/language/in/tag?acceptLanguage=hi,en-GB")
  }

  @Test
  func bestLanguageTagEndpointWithLocalization() throws {
    let url = try MCatalog.bestLanguageTagURL(storefront: "in", languages: ["hi", "en-GB"], localization: "hi")
    expectEndpoint(url, equals: "https://api.music.apple.com/v1/language/in/tag?acceptLanguage=hi,en-GB&l=hi")
  }

  @Test
  func bestLanguageTagEndpointForSingleLanguage() throws {
    let url = try MCatalog.bestLanguageTagURL(storefront: "jp", languages: ["ja"], localization: nil)
    expectEndpoint(url, equals: "https://api.music.apple.com/v1/language/jp/tag?acceptLanguage=ja")
  }

  @Test
  func bestLanguageTagEndpointIgnoresEmptyLocalization() throws {
    let url = try MCatalog.bestLanguageTagURL(storefront: "us", languages: ["en-US"], localization: "")
    expectEndpoint(url, equals: "https://api.music.apple.com/v1/language/us/tag?acceptLanguage=en-US")
  }

  @Test
  func bestLanguageTagEndpointEmptyLanguagesThrows() {
    #expect(throws: MusadoraKitError.languageTagsMissing) {
      _ = try MCatalog.bestLanguageTagURL(storefront: "in", languages: [], localization: nil)
    }
  }

  @Test
  func decodingLanguageTagResponse() throws {
    let json = Data(#"{"results":{"tag":"en-GB"}}"#.utf8)
    let response = try JSONDecoder().decode(LanguageTagResponse.self, from: json)
    #expect(response.results.tag == "en-GB")
  }

  @Test
  func decodingLanguageTagResponseWithoutTagThrows() {
    let json = Data(#"{"results":{}}"#.utf8)
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(LanguageTagResponse.self, from: json)
    }
  }
}
