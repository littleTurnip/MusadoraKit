//
//  MLibraryPlaylistFolder.swift
//
//
//  Created by Rudrank Riyam on 26/12/22.
//

import Foundation
@preconcurrency import MusicKit

/// A collection of playlist folders from the user's library.
///
/// This type alias represents an array of playlist folders that can be retrieved from
/// the user's Apple Music library. Each folder can contain multiple playlists and
/// can be organized hierarchically.
///
/// Example usage:
/// ```swift
/// do {
///     let folder = try await MLibrary.playlistParentFolder(id: "p.example")
///     print("Folder name: \(folder.attributes?.name ?? "Root")")
/// } catch {
///     print("Failed to fetch the parent folder: \(error)")
/// }
/// ```
public typealias LibraryPlaylistFolders = [LibraryPlaylistFolder]

extension MLibrary {
  /// Fetch the folder that contains a library playlist.
  ///
  /// - Parameter id: The unique identifier of the library playlist.
  /// - Returns: The playlist's parent folder.
  /// - Throws: An error if the request fails or the response doesn't contain a parent folder.
  public static func playlistParentFolder(id: MusicItemID) async throws -> LibraryPlaylistFolder {
    let url = try playlistParentFolderURL(id: id)
    let data: Data

    if let userToken = MusadoraKit.userToken {
      let request = MusicUserRequest(urlRequest: .init(url: url), userToken: userToken)
      data = try await request.response()
    } else {
      let request = MusicDataRequest(urlRequest: .init(url: url))
      let response = try await request.response()
      data = response.data
    }

    return try decodePlaylistParentFolder(from: data, playlistID: id)
  }

  internal static func decodePlaylistParentFolder(
    from data: Data,
    playlistID: MusicItemID
  ) throws -> LibraryPlaylistFolder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let response = try decoder.decode(LibraryPlaylistFolderResponse.self, from: data)

    guard let folder = response.data.first else {
      throw MusadoraKitError.notFound(for: "parent folder of \(playlistID.rawValue)")
    }

    return folder
  }

  internal static func playlistParentFolderURL(
    id: MusicItemID,
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlists/\(id.rawValue)/parent"

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }
}

private struct LibraryPlaylistFolderResponse: Decodable {
  let data: LibraryPlaylistFolders
}
