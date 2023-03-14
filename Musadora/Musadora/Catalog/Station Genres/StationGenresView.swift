//
//  StationGenresView.swift
//  Musadora
//
//  Created by Rudrank Riyam on 12/03/23.
//

import SwiftUI
import MusadoraKit

struct StationGenresView: View {
  @State private var stationGenres: StationGenres = []

  var body: some View {
    List {
      ForEach(stationGenres) { stationGenre in
        NavigationLink(destination: {
          StationGenreDetailedView(stationGenre: stationGenre)
        }, label: {
          Text(stationGenre.name)
        })
      }
      .navigationTitle("Station Genres")
    }
    .task {
      await fetchStationGenres()
    }
  }
}

extension StationGenresView {
  private func fetchStationGenres() async {
      do {
        stationGenres = try await MCatalog.stationGenres()
      } catch {
        print(error)
    }
  }
}
