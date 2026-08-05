//
//  MRecommendation+id.swift
//  MusadoraKit
//

public extension MRecommendation {
  /// Retrieve a recommendation for a user by using its identifier.
  ///
  /// The recommendations are determined based
  /// on the user's past interactions and preferences.
  ///
  ///  Example:
  ///   ```swift
  ///  do  {
  ///    let id: MusicItemID = "6-27s5hU6azhJY"
  ///    let recommendation = try await MRecommendation.recommendation(id: id)
  ///  } catch {
  ///    // Handle the error.
  ///  }
  ///  ```
  ///
  /// - Note: This is a personalized endpoint that requires user authorization.
  /// The request uses the music user token stored in `MusadoraKit.userToken` when available,
  /// and falls back to MusicKit's own authorization otherwise.
  ///
  /// - Parameters:
  ///   - id: The unique identifier for the recommendation.
  ///   - limit: The maximum number of objects to retrieve in the recommendation response. If not specified, the default value is used. The maximum value is 30.
  /// - Returns: `MusicRecommendationItem` matching the given identifier, containing albums, playlists and/or stations.
  /// - Throws: `MusadoraKitError.notFound` if no recommendation exists for the given identifier,
  /// or `MusadoraKitError.recommendationOverLimit` if the limit is over 30.
  static func recommendation(id: MusicItemID, limit: Int? = nil) async throws -> MusicRecommendationItem {
    let request = recommendationRequest(id: id, limit: limit)
    let response = try await request.response()

    guard let recommendation = response.items.first else {
      throw MusadoraKitError.notFound(for: id.rawValue)
    }
    return recommendation
  }

  /// Retrieve one or more recommendations for a user by using their identifiers.
  ///
  /// The recommendations are determined based
  /// on the user's past interactions and preferences.
  ///
  ///  Example:
  ///   ```swift
  ///  do  {
  ///    let ids: [MusicItemID] = ["6-27s5hU6azhJY", "6-27s5hU6azhJa"]
  ///    let recommendations = try await MRecommendation.recommendations(ids: ids)
  ///  } catch {
  ///    // Handle the error.
  ///  }
  ///  ```
  ///
  /// - Note: This is a personalized endpoint that requires user authorization.
  /// The request uses the music user token stored in `MusadoraKit.userToken` when available,
  /// and falls back to MusicKit's own authorization otherwise.
  ///
  /// - Parameters:
  ///   - ids: The unique identifiers for the recommendations.
  ///   - limit: The maximum number of objects to retrieve in the recommendation response. If not specified, the default value is used. The maximum value is 30.
  /// - Returns: A collection of `MusicRecommendationItem` objects matching the given identifiers, each representing a recommendation
  /// item containing albums, playlists and/or stations.
  /// - Throws: `MusadoraKitError.idMissing` if the identifiers are empty,
  /// or `MusadoraKitError.recommendationOverLimit` if the limit is over 30.
  static func recommendations(ids: [MusicItemID], limit: Int? = nil) async throws -> MusicRecommendations {
    let request = try recommendationsRequest(ids: ids, limit: limit)
    let response = try await request.response()
    return response.items
  }
}

extension MRecommendation {
  static func recommendationRequest(id: MusicItemID, limit: Int?) -> MusicRecommendationRequest {
    var request = MusicRecommendationRequest(equalTo: id.rawValue)
    request.limit = limit
    return request
  }

  static func recommendationsRequest(ids: [MusicItemID], limit: Int?) throws -> MusicRecommendationRequest {
    guard !ids.isEmpty else {
      throw MusadoraKitError.idMissing
    }

    var request = MusicRecommendationRequest(memberOf: ids.map { $0.rawValue })
    request.limit = limit
    return request
  }
}
