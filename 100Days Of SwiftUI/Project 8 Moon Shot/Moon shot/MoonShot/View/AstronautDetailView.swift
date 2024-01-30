//
//  AstronautDetailView.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/23.
//

import SwiftUI

struct AstronautDetailView: View {
    let astronaut: Astronaut

    var body: some View {
        ScrollView {
            VStack {
                Image(astronaut.id)
                    .resizable()
                    .scaledToFit()

                Text(astronaut.description)
                    .padding()
            }
        }
        .preferredColorScheme(.dark) //특정 View의 스키마를 다크모드로 지정할수 있음
        .navigationTitle(astronaut.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")

    return AstronautDetailView(astronaut: astronauts["aldrin"]!)
}
