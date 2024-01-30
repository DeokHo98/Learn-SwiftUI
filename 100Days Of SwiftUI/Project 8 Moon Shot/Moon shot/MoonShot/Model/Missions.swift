//
//  Missions.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/23.
//

import SwiftUI

struct Mission: Codable, Identifiable {
    struct CrewRole: Codable {
        let name: String
        let role: String
    }

    let id: Int
    let launchDate: String?
    let crew: [CrewRole]
    let description: String
    
    var displayName: String {
        "Apollo \(id)"
    }

    var image: String {
        "apollo\(id)"
    }
}

struct CrewMember {
    let role: String
    let astronaut: Astronaut
}

