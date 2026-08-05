//
//  LibraryPlaylistFolderChildren.swift
//  MusadoraKit
//
//  Created by Rudrank Riyam on 05/08/26.
//

import Foundation

/// The children of a library playlist folder, split by resource type.
///
/// A playlist folder in the user's library can contain both playlists and
/// nested subfolders. This structure groups the folder's children by type.
///
/// Example usage:
/// ```swift
/// let children = try await MLibrary.playlistFolderChildren(forFolderID: "p.WmzVVDOUO9pDBk")
///
/// for playlist in children.playlists {
///     print("Playlist: \(playlist.attributes.name)")
/// }
///
/// for folder in children.folders {
///     print("Subfolder: \(folder.attributes?.name ?? folder.id)")
/// }
/// ```
public struct LibraryPlaylistFolderChildren: Sendable {
  /// The subfolders contained in the playlist folder.
  public let folders: LibraryPlaylistFolders

  /// The playlists contained in the playlist folder.
  public let playlists: LibraryPlaylists
}
