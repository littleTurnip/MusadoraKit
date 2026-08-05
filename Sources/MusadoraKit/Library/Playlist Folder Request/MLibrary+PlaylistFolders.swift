//
//  MLibrary+PlaylistFolders.swift
//  MusadoraKit
//
//  Created by Rudrank Riyam on 05/08/26.
//

import Foundation

public extension MLibrary {
  /// Fetch the root library playlists folder of the user's library.
  ///
  /// The root folder is the top-level container for all the playlists and playlist
  /// folders in the user's library. Use its identifier as the parent when creating
  /// a folder at the top level, or fetch its children to walk the folder hierarchy.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let rootFolder = try await MLibrary.rootPlaylistsFolder()
  ///     print("Root folder identifier: \(rootFolder.id)")
  /// } catch {
  ///     print("Failed to fetch the root playlists folder: \(error)")
  /// }
  /// ```
  ///
  /// - Returns: The `LibraryPlaylistFolder` representing the root playlists folder.
  /// - Throws: An error if the request fails or the response doesn't contain the root folder.
  ///
  /// - Note: This method requires a music user token.
  static func rootPlaylistsFolder() async throws -> LibraryPlaylistFolder {
    let url = try rootPlaylistsFolderURL()
    let data = try await playlistFolderData(for: url)
    return try decodeRootPlaylistsFolder(from: data)
  }

  /// Fetch a playlist folder from the user's library by using its identifier.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let folder = try await MLibrary.playlistFolder(id: "p.WmzVVDOUO9pDBk")
  ///     print("Folder name: \(folder.attributes?.name ?? "")")
  /// } catch {
  ///     print("Failed to fetch the playlist folder: \(error)")
  /// }
  /// ```
  ///
  /// - Parameter id: The unique identifier of the library playlist folder.
  /// - Returns: The `LibraryPlaylistFolder` matching the given identifier.
  /// - Throws: An error if the request fails or the folder could not be found.
  ///
  /// - Note: This method requires a music user token.
  static func playlistFolder(id: MusicItemID) async throws -> LibraryPlaylistFolder {
    let url = try playlistFolderURL(id: id)
    let data = try await playlistFolderData(for: url)
    return try decodePlaylistFolder(from: data, id: id)
  }

  /// Fetch multiple playlist folders from the user's library by using their identifiers.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let ids: [MusicItemID] = ["p.WmzVVDOUO9pDBk", "p.RB1AA8bCv74Zkl"]
  ///     let folders = try await MLibrary.playlistFolders(ids: ids)
  ///
  ///     for folder in folders {
  ///         print("Folder name: \(folder.attributes?.name ?? "")")
  ///     }
  /// } catch {
  ///     print("Failed to fetch the playlist folders: \(error)")
  /// }
  /// ```
  ///
  /// - Parameter ids: The unique identifiers of the library playlist folders.
  /// - Returns: The `LibraryPlaylistFolders` matching the given identifiers.
  /// - Throws: `MusadoraKitError.idMissing` if `ids` is empty, or an error if the request fails.
  ///
  /// - Note: This method requires a music user token.
  static func playlistFolders(ids: [MusicItemID]) async throws -> LibraryPlaylistFolders {
    let url = try playlistFoldersURL(ids: ids)
    let data = try await playlistFolderData(for: url)
    return try decodePlaylistFolders(from: data)
  }

  /// Fetch the children of a playlist folder in the user's library.
  ///
  /// A playlist folder can contain both playlists and nested subfolders.
  /// The result groups the children by resource type.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let children = try await MLibrary.playlistFolderChildren(forFolderID: "p.WmzVVDOUO9pDBk")
  ///
  ///     for playlist in children.playlists {
  ///         print("Playlist: \(playlist.attributes.name)")
  ///     }
  ///
  ///     for folder in children.folders {
  ///         print("Subfolder: \(folder.attributes?.name ?? folder.id)")
  ///     }
  /// } catch {
  ///     print("Failed to fetch the folder's children: \(error)")
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the library playlist folder.
  ///   - limit: The number of children to return. The Apple Music API defaults to 25,
  ///     with a maximum of 100.
  /// - Returns: The `LibraryPlaylistFolderChildren` containing the folder's playlists and subfolders.
  /// - Throws: An error if the request fails or the response can't be decoded.
  ///
  /// - Note: This method requires a music user token.
  static func playlistFolderChildren(forFolderID id: MusicItemID, limit: Int? = nil) async throws -> LibraryPlaylistFolderChildren {
    let url = try playlistFolderChildrenURL(forFolderID: id, limit: limit)
    let data = try await playlistFolderData(for: url)
    return try decodePlaylistFolderChildren(from: data)
  }

  /// Fetch the parent folder of a playlist folder in the user's library.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let parent = try await MLibrary.parentFolder(forFolderID: "p.WmzVVDOUO9pDBk")
  ///     print("Parent folder identifier: \(parent.id)")
  /// } catch {
  ///     print("Failed to fetch the parent folder: \(error)")
  /// }
  /// ```
  ///
  /// - Parameter id: The unique identifier of the library playlist folder.
  /// - Returns: The `LibraryPlaylistFolder` that contains the given folder.
  /// - Throws: An error if the request fails or the response doesn't contain a parent folder.
  ///
  /// - Note: This method requires a music user token.
  static func parentFolder(forFolderID id: MusicItemID) async throws -> LibraryPlaylistFolder {
    let url = try playlistFolderParentURL(forFolderID: id)
    let data = try await playlistFolderData(for: url)
    return try decodePlaylistFolderParent(from: data, folderID: id)
  }

  /// Create a new playlist folder in the user's library.
  ///
  /// Use this method to create a playlist folder with the given name. Pass the identifier
  /// of an existing folder as the parent to nest the new folder inside it. When no parent
  /// is provided, Apple Music creates the folder at the top level of the user's library.
  ///
  /// Example usage:
  /// ```swift
  /// do {
  ///     let folder = try await MLibrary.createPlaylistFolder(name: "Workout Mixes")
  ///     print("Created folder: \(folder.attributes?.name ?? "")")
  ///
  ///     let nestedFolder = try await MLibrary.createPlaylistFolder(name: "Running", parentID: folder.id)
  ///     print("Created nested folder: \(nestedFolder.attributes?.name ?? "")")
  /// } catch {
  ///     print("Failed to create the playlist folder: \(error)")
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - name: The name of the new playlist folder.
  ///   - parentID: The unique identifier of the folder to nest the new folder in.
  ///     Use `p.playlistsroot` or `nil` for a top-level folder.
  /// - Returns: The newly created `LibraryPlaylistFolder`.
  /// - Throws: An error if the folder could not be created or the response can't be decoded.
  ///
  /// - Note: This method requires a music user token.
  static func createPlaylistFolder(name: String, parentID: MusicItemID? = nil) async throws -> LibraryPlaylistFolder {
    let url = try createPlaylistFolderURL()

    var creationRequest = LibraryPlaylistFolderCreationRequest(attributes: .init(name: name))

    if let parentID {
      creationRequest.relationships = .init(parent: .init(data: [.init(id: parentID.rawValue)]))
    }

    let data = try JSONEncoder().encode(creationRequest)

    let request = MusicPostRequest(url: url, data: data)
    let response = try await request.response()

    guard let folder = try decodePlaylistFolders(from: response.data).first else {
      throw MusadoraKitError.notFound(for: name)
    }

    return folder
  }
}

// MARK: - Decoding
extension MLibrary {
  internal static func decodeRootPlaylistsFolder(from data: Data) throws -> LibraryPlaylistFolder {
    let response = try playlistFolderDecoder.decode(LibraryPlaylistFoldersResponse.self, from: data)

    guard let folder = response.data.first ?? response.meta?.filters?.identity?.playlistsroot?.first else {
      throw MusadoraKitError.notFound(for: "root playlists folder")
    }

    return folder
  }

  internal static func decodePlaylistFolder(from data: Data, id: MusicItemID) throws -> LibraryPlaylistFolder {
    guard let folder = try decodePlaylistFolders(from: data).first else {
      throw MusadoraKitError.notFound(for: id.rawValue)
    }

    return folder
  }

  internal static func decodePlaylistFolderParent(from data: Data, folderID: MusicItemID) throws -> LibraryPlaylistFolder {
    guard let folder = try decodePlaylistFolders(from: data).first else {
      throw MusadoraKitError.notFound(for: "parent folder of \(folderID.rawValue)")
    }

    return folder
  }

  internal static func decodePlaylistFolders(from data: Data) throws -> LibraryPlaylistFolders {
    try playlistFolderDecoder.decode(LibraryPlaylistFoldersResponse.self, from: data).data
  }

  internal static func decodePlaylistFolderChildren(from data: Data) throws -> LibraryPlaylistFolderChildren {
    let response = try playlistFolderDecoder.decode(LibraryPlaylistFolderChildrenResponse.self, from: data)

    var folders: LibraryPlaylistFolders = []
    var playlists: [LibraryPlaylist] = []

    for child in response.data {
      switch child {
      case let .folder(folder):
        folders.append(folder)
      case let .playlist(playlist):
        playlists.append(playlist)
      }
    }

    return LibraryPlaylistFolderChildren(folders: folders, playlists: LibraryPlaylists(playlists))
  }

  private static var playlistFolderDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }

  private static func playlistFolderData(for url: URL) async throws -> Data {
    if let userToken = MusadoraKit.userToken {
      let request = MusicUserRequest(urlRequest: .init(url: url), userToken: userToken)
      return try await request.response()
    } else {
      let request = MusicDataRequest(urlRequest: .init(url: url))
      let response = try await request.response()
      return response.data
    }
  }
}

// MARK: - Endpoint URLs
extension MLibrary {
  internal static func rootPlaylistsFolderURL(
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlist-folders"
    components.queryItems = [URLQueryItem(name: "filter[identity]", value: "playlistsroot")]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }

  internal static func playlistFolderURL(
    id: MusicItemID,
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlist-folders/\(id.rawValue)"

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }

  internal static func playlistFoldersURL(
    ids: [MusicItemID],
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    guard !ids.isEmpty else {
      throw MusadoraKitError.idMissing
    }

    var components = components
    components.path = "me/library/playlist-folders"
    components.queryItems = [URLQueryItem(name: "ids", value: ids.map(\.rawValue).joined(separator: ","))]

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }

  internal static func playlistFolderChildrenURL(
    forFolderID id: MusicItemID,
    limit: Int? = nil,
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlist-folders/\(id.rawValue)/children"

    if let limit {
      components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
    }

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }

  internal static func playlistFolderParentURL(
    forFolderID id: MusicItemID,
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlist-folders/\(id.rawValue)/parent"

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }

  internal static func createPlaylistFolderURL(
    components: MusicURLComponents = AppleMusicURLComponents()
  ) throws -> URL {
    var components = components
    components.path = "me/library/playlist-folders"

    guard let url = components.url else {
      throw URLError(.badURL)
    }

    return url
  }
}

/// The response to a library playlist folders request.
private struct LibraryPlaylistFoldersResponse: Decodable {
  /// The playlist folders returned by Apple Music.
  let data: LibraryPlaylistFolders

  /// The metadata returned by Apple Music, containing the applied filters.
  let meta: Meta?

  /// The metadata for a library playlist folders response.
  struct Meta: Decodable {
    /// The filters applied to the request.
    let filters: Filters?
  }

  /// The filters applied to a library playlist folders request.
  struct Filters: Decodable {
    /// The identity filter results.
    let identity: Identity?
  }

  /// The identity filter results of a library playlist folders request.
  struct Identity: Decodable {
    /// The root playlists folder resources returned by Apple Music.
    let playlistsroot: LibraryPlaylistFolders?
  }
}

/// The response to a library playlist folder children request.
private struct LibraryPlaylistFolderChildrenResponse: Decodable {
  /// The children returned by Apple Music.
  let data: [LibraryPlaylistFolderChildItem]
}

/// A child of a library playlist folder, which is either a playlist or a subfolder.
private enum LibraryPlaylistFolderChildItem: Decodable {
  case folder(LibraryPlaylistFolder)
  case playlist(LibraryPlaylist)

  private enum CodingKeys: String, CodingKey {
    case type
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    if type == "library-playlist-folders" {
      self = .folder(try LibraryPlaylistFolder(from: decoder))
    } else {
      self = .playlist(try LibraryPlaylist(from: decoder))
    }
  }
}
