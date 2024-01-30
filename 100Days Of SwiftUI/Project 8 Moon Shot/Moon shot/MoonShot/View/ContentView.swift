//
//  ContentView.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/19.
//

import SwiftUI
struct ContentView: View {
    
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")
    
    let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack { //네비게이션 Stack
            ScrollView { //수직 스크롤뷰
                LazyVGrid(columns: columns) { // 수직 그리드 뷰
                    ForEach(missions) { mission in //ForEech를 상용해 missons 배열에 데이터 꺼내오기
                        NavigationLink { //그리드 선택시 상세화면 열리게 구현
                            MissionDetailView(mission: mission, astronauts: astronauts)
                        } label: {
                            //여기부턴 그리드안에 세부 항목 UIKit에서 cell같은 느낌
                            MissionGridView(mission: mission)
                        }
                    }
                }
            }
            .navigationTitle("Moonshot")
        }
        .preferredColorScheme(.dark) //특정 View의 스키마를 다크모드로 지정할수 있음
    }
}



#Preview {
    ContentView()
}
