//
//  ContentView.swift
//  ImageFeedSwiftUI
//
//  Created by Kalaiprabha L on 27/06/22.
//

import SwiftUI
import SwiftUIInfiniteList
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ImageFeedViewModel(service: DataNetworkService())
    
    var page: Int = 0
    
    let columns: [GridItem] =
    Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.photos, id: \.self) { photo in
                    GridCell(photo: photo)
                        .onAppear {
                            Task {
                                if viewModel.photos.last == photo {
                                    await fetchData()
                                }
                            }
                        }
                }
            }
            .errorAlert(error: $viewModel.alertMessage)
            .task {
                await fetchData()
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
    func fetchData() async {
        await self.viewModel.fetchPhotosForOffset(page, request: PhotoDataRequest(endPoint: URLEndPoint.list))
    }
}

extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
