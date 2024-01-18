//
//  ContentView.swift
//  WordScramble
//
//  Created by Paul Hudson on 15/10/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Word", text: $newWord)
                    //첫글자 대문자 비활성화
                        .textInputAutocapitalization(.never)
                }
                .onSubmit {
                    addNewWord()
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
        .navigationTitle(rootWord)
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }

        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
}

#Preview {
    ContentView()
}
