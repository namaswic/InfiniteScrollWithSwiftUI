//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Namaswi Chandarana on 25/04/23.
//

import SwiftUI

struct AsyncPicture: View {
    private let url: String

    init(url: String) {
        self.url = url
    }

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "exclamationmark.icloud.fill")
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = ImageViewModel()

    var body: some View {
        List(viewModel.images) { image in
            AsyncImage(url: URL(string: image.download_url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "exclamationmark.icloud.fill")
                @unknown default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("SwiftUI Infinite Scroll")
        .onAppear(perform: viewModel.fetchData)
    }
}

class ImageViewModel: ObservableObject {
    @Published var images = [ImageModel]()
    private var page = 1
    private let limit = 100

    func fetchData() {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=1&limit=100") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            do {
                let images = try decoder.decode([ImageModel].self, from: data)
                DispatchQueue.main.async {
                    self.images.append(contentsOf: images)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

struct ImageModel: Codable, Identifiable {
    let id: String
    let download_url: String
}
