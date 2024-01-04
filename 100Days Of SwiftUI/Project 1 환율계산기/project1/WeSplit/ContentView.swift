//
//  ContentView.swift
//  WeSplit
//
//  Created by Paul Hudson on 07/10/2023.
//

import SwiftUI

/*

 */
struct ContentView: View {
    
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 0
    @State private var tipPercentage = 20
    
    @State private var tipPercentages = [10, 15, 20, 25, 50]
    
    @FocusState private var amountIsFocused: Bool
    
    private var perPersonTip: Double {
        let tipAmount = checkAmount * Double(tipPercentage) / 100.0
        let totalAmount = checkAmount + tipAmount
        return totalAmount / Double(numberOfPeople + 2)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "Amount",
                        value: $checkAmount,
                        format: .currency(code: Locale.current.currency?.identifier ?? "KRW")
                    )
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                }
                
                Section {
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2..<100) {
                            Text("\($0) people")
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(tipPercentages, id: \.self) {
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Text("per person tip: \(perPersonTip.rounded())")
                    .pickerStyle(.segmented)
                }
            }
            .onTapGesture {
                amountIsFocused = false
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("WeSplit")
        }
    }
}

#Preview {
    ContentView()
}
    
