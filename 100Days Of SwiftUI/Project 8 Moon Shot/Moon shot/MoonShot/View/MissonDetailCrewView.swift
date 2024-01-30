//
//  MissonDetailCrewView.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/23.
//

import SwiftUI

struct MissonDetailCrewView: View {
    
    let mission: Mission
    let crew: [CrewMember]
    
    init(mission: Mission, astronauts: [String: Astronaut]) {
        self.mission = mission

        self.crew = mission.crew.map { member in
            if let astronaut = astronauts[member.name] {
                return CrewMember(role: member.role, astronaut: astronaut)
            } else {
                fatalError("Missing \(member.name)")
            }
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(crew, id: \.role) { crewMember in
                    NavigationLink {
                        AstronautDetailView(astronaut: crewMember.astronaut)
                    } label: {
                        HStack {
                            Image(crewMember.astronaut.id)
                                .resizable()
                                .frame(width: 104, height: 72)
                                .clipShape(Capsule()) //뷰의 모양 변경
                                .overlay(
                                    Capsule().stroke(Color.white, lineWidth: 1) //
                                ) //테두리를 넣을땐 항상 clipShape과 일치하는 모양이어야 함

                            VStack(alignment: .leading) {
                                Text(crewMember.astronaut.name)
                                    .foregroundStyle(.white)
                                    .font(.headline)
                                Text(crewMember.role)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")

    return MissonDetailCrewView(mission: missions[0], astronauts: astronauts)
}
