//
//  ContentView.swift
//  Animations
//
//  Created by Paul Hudson on 15/10/2023.
//

import SwiftUI

struct HiddenModifier: ViewModifier {
    
    var isHidden: Bool

    func body(content: Content) -> some View {
        if isHidden == false {
            content
        }
    }
}

struct ContentView: View {
    
    @State private var isShowingRed = false

    var body: some View {
        VStack {
            Button("Tap Me") {
                withAnimation {
                    isShowingRed.toggle()
                }
            }
            Rectangle()
                .fill(.red)
                .frame(width: 200, height: 200)
                .modifier(HiddenModifier(isHidden: isShowingRed))
        }
    }
}

#Preview {
    ContentView()
}
