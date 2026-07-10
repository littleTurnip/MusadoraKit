//
//  LibraryPlaylistParentRelationship.swift
//  MusadoraKit
//

/// A relationship containing a library playlist's parent folder.
public struct LibraryPlaylistParentRelationship: Codable, Sendable {
  /// The parent folder resources returned by Apple Music.
  public let data: LibraryPlaylistFolders
}
