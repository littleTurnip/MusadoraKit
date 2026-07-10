//
//  LibraryPlaylistProperties.swift
//  MusadoraKit
//

/// An additional relationship to include with a library playlist.
public enum LibraryPlaylistProperty: String, Sendable {
  /// The folder that contains the playlist.
  case parent
}

/// Additional relationships to include with library playlists.
public typealias LibraryPlaylistProperties = [LibraryPlaylistProperty]
