//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Paul Hudson on 11/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    //나라를 셔플하기위해선 @State를 붙혀야함

    @State private var countries = ["Estonia", "France", "Germany",
                     "Ireland", "Italy", "Nigeria",
                     "Poland", "Spain", "UK",
                     "Ukraine", "US"].shuffled()
    //score 역시 계속 변하는값
    @State private var score: Int = 0
    //showAlert 값으로 alert 노출을 결정
    @State private var showAlert: Bool = false
    //단순히 성공과 실패 메시지를 다르게 하기위해서 사용 String으로 해도 될듯
    @State private var isSuccess: Bool = false
    //이값이 바껴야 정답 위치가 변함
    @State var correctAnswer = Int.random(in: 0...2)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                VStack(spacing: 30) {
                    Text("Score: \(score)")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                    
                    Text("Tap the flag of")
                        .foregroundStyle(.white)
                        .font(.subheadline.weight(.heavy))
                    
                    Text(countries[correctAnswer])
                        .foregroundStyle(.white)
                        .font(.largeTitle.weight(.semibold))
                }
                ForEach(0..<3) { number in
                    Button {
                        flagTapped(number)
                    } label: {
                        Image(countries[number])
                            .border(.white)

                            .shadow(radius: 5)
                    }
                 
                }
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("\(isSuccess ? "성공" : "실패")"))
        })
    }
    
    private func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
            isSuccess = true
        } else {
            score -= 1
            isSuccess = false
        }
        showAlert = true
        correctAnswer = Int.random(in: 0...2)
        countries.shuffle()
    }
}

#Preview {
    ContentView()
}
