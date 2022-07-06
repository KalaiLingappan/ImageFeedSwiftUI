//
//  ContentView.swift
//  ImageFeedSwiftUI
//
//  Created by Kalaiprabha L on 27/06/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List() {
            ForEach(0..<3) { row in
                HStack {
                    ForEach(0..<2) { column in
                        GridCell(title: "\(column)")
                    }
                }
            }
        }
        .padding(0.0)
    }
}

struct GridCell: View {
    let title: String
    var body: some View {
        ZStack {
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .background(.white)
                .overlay(alignment: .bottom, content: {
                    Text(title)
                        .frame(height: 30)
                        .foregroundColor(.black)
                        .font(.title3)
                })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
