//
//  MissionGridView.swift
//  MoonShot
//
//  Created by Jeong Deokho on 2024/01/23.
//

import SwiftUI

struct MissionGridView: View {
    
    let mission: Mission
    
    var body: some View {
        VStack { //수직 스택 생성
            Image(mission.image) //처음엔 Image
                .resizable() //공간에 맞게 이미지 크기를 조정
                .scaledToFit() //View 크기가 조정될대 뷰의 종횡비는 유지하면서 이뷰의 크기를 부모에 맞게 조정
                .frame(width: 100, height: 100)
            //넓이 높이 100의 이미지로 변환

            VStack {
                Text(mission.displayName) //미션 이름 Text
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(mission.launchDate ?? "N/A") //미션 날짜 Text
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical, 30) //top 과 bottom에 모두 30만큼 간격을 넣는 .vertical
            .frame(maxWidth: .infinity) //maxWidth는 해당 View 최대 넓이 만큼 (그리드 한개의 최대 넓이)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue)
            ) //모서리를 둥글게
            .padding(10) //모든 방향의 padding을 10
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    return MissionGridView(mission: missions[0])
}
