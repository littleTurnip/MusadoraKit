//
//  MusicLibraryResourceRequest.swift
//  MusadoraKit
//
//  Created by Rudrank Riyam on 02/04/22.
//

import Foundation

/// A request that your app uses to fetch items from the user's library
/// using a filter.
struct MusicLibraryResourceRequest<MusicItemType: MusicItem & Codable> {
  /// A limit for the number of items to return
  /// in the catalog resource response.
  var limit: Int?

  /// Creates a request to fetch all the items in alphabetical order.
  init() {
    setType()
  }

  /// Creates a request to fetch items using a filter that matches
  /// a specific value.
  init<Value>(matching _: KeyPath<MusicItemType.FilterLibraryType, Value>, equalTo value: Value) where MusicItemType: FilterableLibraryItem {
    setType()

    if let id = value as? MusicItemID {
      filter = .ids([id.rawValue])
    } else {
      filter = .unsupported
    }
  }

  /// Creates a request to fetch items using a filter that matches
  /// any value from an array of possible values.
  init<Value>(matching _: KeyPath<MusicItemType.FilterLibraryType, Value>, memberOf values: [Value]) where MusicItemType: FilterableLibraryItem {
    setType()

    if let ids = values as? [MusicItemID] {
      filter = .ids(ids.map { $0.rawValue })
    } else {
      filter = .unsupported
    }
  }

  /// Fetches items from the user's library that match a specific filter.
  func response() async throws -> MusicLibraryResourceResponse<MusicItemType> {
    let url = try libraryEndpointURL
    let decoder = JSONDecoder()

    if let userToken = MusadoraKit.userToken {
      let request = MusicUserRequest(urlRequest: .init(url: url), userToken: userToken)
      let data = try await request.response()
      let items = try decoder.decode(MusicItemCollection<MusicItemType>.self, from: data)
      return MusicLibraryResourceResponse(items: items)
    } else {
      let request = MusicDataRequest(urlRequest: URLRequest(url: url))
      let response = try await request.response()
      let items = try decoder.decode(MusicItemCollection<MusicItemType>.self, from: response.data)
      return MusicLibraryResourceResponse(items: items)
    }
  }

  private var type: LibraryMusicItemType?
  private var filter: LibraryResourceFilter?
}

private enum LibraryResourceFilter {
  case ids([String])
  case unsupported
}

extension MusicLibraryResourceRequest {
  private mutating func setType() {
    switch MusicItemType.self {
    case is Song.Type:
      type = .songs
    case is Album.Type:
      type = .albums
    case is Artist.Type:
      type = .artists
    case is MusicVideo.Type:
      type = .musicVideos
    case is Playlist.Type:
      type = .playlists
    default:
      type = nil
    }
  }

  internal var libraryEndpointURL: URL {
    get throws {
      guard let type = type else { throw URLError(.badURL) }

      var components = AppleMusicURLComponents()
      var queryItems: [URLQueryItem] = []

      components.path = "me/library/\(type.rawValue)"

      switch filter {
      case let .ids(ids):
        guard !ids.isEmpty else {
          throw MusadoraKitError.idMissing
        }
        queryItems += [URLQueryItem(name: "ids", value: ids.joined(separator: ","))]
      case .unsupported:
        throw MusadoraKitError.unsupportedLibraryFilter
      case nil:
        break
      }

      if let limit = limit {
        queryItems += [URLQueryItem(name: "limit", value: "\(limit)")]
      }

      queryItems += [
        URLQueryItem(name: "fields[albums]", value: "artistName,artistUrl,artwork,contentRating,editorialArtwork,name,playParams,releaseDate,url"),
        URLQueryItem(name: "fields[artists]", value: "name,url"),
        URLQueryItem(name: "includeOnly", value: "catalog,artists"),
        URLQueryItem(name: "include[albums]", value: "artists"),
        URLQueryItem(name: "include[library-albums]", value: "artists")
      ]

      components.queryItems = queryItems.isEmpty ? nil : queryItems

      guard let url = components.url else {
        throw URLError(.badURL)
      }

      return url
    }
  }
}
