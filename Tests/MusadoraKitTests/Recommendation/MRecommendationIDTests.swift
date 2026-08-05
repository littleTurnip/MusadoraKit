//
//  MRecommendationIDTests.swift
//  MusadoraKitTests
//

@testable import MusadoraKit
import MusicKit
import Testing

@Suite
struct MRecommendationIDTests {
  @Test
  func recommendationRequestByIDEndpointURL() throws {
    let id: MusicItemID = "6-27s5hU6azhJY"
    let request = MRecommendation.recommendationRequest(id: id, limit: nil)
    let url = try request.recommendationEndpointURL

    expectEndpoint(url, equals: "https://api.music.apple.com/v1/me/recommendations?ids=6-27s5hU6azhJY")
  }

  @Test
  func recommendationRequestByIDWithLimitEndpointURL() throws {
    let id: MusicItemID = "6-27s5hU6azhJY"
    let request = MRecommendation.recommendationRequest(id: id, limit: 2)
    let url = try request.recommendationEndpointURL

    expectEndpoint(url, equals: "https://api.music.apple.com/v1/me/recommendations?ids=6-27s5hU6azhJY&limit=2")
  }

  @Test
  func recommendationsRequestByIDsEndpointURL() throws {
    let ids: [MusicItemID] = ["6-27s5hU6azhJY", "6-27s5hU6azhJa"]
    let request = try MRecommendation.recommendationsRequest(ids: ids, limit: nil)
    let url = try request.recommendationEndpointURL

    expectEndpoint(url, equals: "https://api.music.apple.com/v1/me/recommendations?ids=6-27s5hU6azhJY,6-27s5hU6azhJa")
  }

  @Test
  func recommendationsRequestByIDsWithLimitEndpointURL() throws {
    let ids: [MusicItemID] = ["6-27s5hU6azhJY", "6-27s5hU6azhJa"]
    let request = try MRecommendation.recommendationsRequest(ids: ids, limit: 5)
    let url = try request.recommendationEndpointURL

    expectEndpoint(url, equals: "https://api.music.apple.com/v1/me/recommendations?ids=6-27s5hU6azhJY,6-27s5hU6azhJa&limit=5")
  }

  @Test
  func recommendationsRequestWithEmptyIDsThrowsIDMissingError() {
    let error = #expect(throws: MusadoraKitError.self) {
      try MRecommendation.recommendationsRequest(ids: [], limit: nil)
    }
    #expect(error == MusadoraKitError.idMissing)
  }

  @Test
  func recommendationRequestByIDWithOverLimitThrowsOverLimitError() {
    let limit = 31
    let id: MusicItemID = "6-27s5hU6azhJY"
    let request = MRecommendation.recommendationRequest(id: id, limit: limit)

    let error = #expect(throws: MusadoraKitError.self) {
      try request.recommendationEndpointURL
    }
    #expect(error == MusadoraKitError.recommendationOverLimit(for: limit))
  }

  @Test
  func recommendationsRequestByIDsWithOverLimitThrowsOverLimitError() throws {
    let limit = 31
    let ids: [MusicItemID] = ["6-27s5hU6azhJY", "6-27s5hU6azhJa"]
    let request = try MRecommendation.recommendationsRequest(ids: ids, limit: limit)

    let error = #expect(throws: MusadoraKitError.self) {
      try request.recommendationEndpointURL
    }
    #expect(error == MusadoraKitError.recommendationOverLimit(for: limit))
  }
}
