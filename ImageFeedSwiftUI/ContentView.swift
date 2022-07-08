//
//  ContentView.swift
//  ImageFeedSwiftUI
//
//  Created by Kalaiprabha L on 27/06/22.
//

import SwiftUI
import SwiftUIInfiniteList

struct ContentView: View {
    @State var results: [Photo] = []
    var page: Int = 0
    
    let columns: [GridItem] =
    Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(results, id: \.self) { photo in
                    GridCell(photo: photo)
                        .onAppear {
                            if results.last == photo {
                                fetchData(page: page + 1)
                            }
                        }
                }
            }
            .task {
                self.fetchData(page: page)
            }
        }
    }
}


struct GridCell: View {
    let photo: Photo

    var body: some View {
        ZStack {
            AsyncImage(url: PhotoCellViewModel(photo).url)
                .frame(height: 300)
                .overlay(alignment: .bottom, content: {
                    Text(photo.author ?? "")
                        .frame(height: 30)
                        .foregroundColor(.white)
                        .font(.caption)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension ContentView {
    func fetchData(page: Int = 0) {
        DataNetworkService().fetchDataFor(request: PhotoDataRequest(endPoint: URLEndPoint.list)) { results in
            switch results {
            case .success(let data):
                self.results += data
            case .failure(let error):
                print(error)
            }
        }
    }
}
