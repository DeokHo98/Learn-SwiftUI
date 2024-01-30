//
//  MissionDetailView.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/23.
//

import SwiftUI

struct MissionDetailView: View {
    
    let mission: Mission
    let astronauts: [String : Astronaut]
    
    var body: some View {
        ScrollView {
            VStack {
                Image(mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                    .padding(.top)
                
                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    
                    Text(mission.description)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            HStack {
                MissonDetailCrewView(mission: mission, astronauts: astronauts)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle(mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}


#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")

    
    return MissionDetailView(mission: missions[0], astronauts: astronauts)
}
