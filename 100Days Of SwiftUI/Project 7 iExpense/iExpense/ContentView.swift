//
//  ContentView.swift
//  iExpense
//
//  Created by Paul Hudson on 15/10/2023.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id: UUID = .init()
    let name: String
    let type: String
    let amount: Double
    
    init(name: String, type: String, amount: Double) {
        self.name = name + id.uuidString
        self.type = type
        self.amount = amount
    }
}

@Observable
class Expenses: Codable {
    var items: [ExpenseItem] = [] {
        didSet {
            let key: String = "Expenses"
            guard let newExpensesData = try? JSONEncoder().encode(self) else { return }
            UserDefaults.standard.setValue(newExpensesData, forKey: key)
        }
    }
    
    init() {
        self.items = []
        let key: String = "Expenses"
        guard let expensesData = UserDefaults.standard.data(forKey: key) else { return }
        guard let expenses = try? JSONDecoder().decode(Expenses.self, from: expensesData) else { return }
        items = expenses.items
    }
}

struct ContentView: View {
    
    @State private var showingAddExpense = false
    @State private var expenses = Expenses()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses.items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button("remove") {
                            removeItems(at: item.id)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onDelete(perform: { indexSet in
                    removeItems(at: indexSet)
                })
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
            

        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
        saveItems()
    }
    
    
    func removeItems(at id: UUID) {
        withAnimation {
            expenses.items.removeAll { $0.id == id }
            saveItems()
        }
    }
    
    func saveItems() {
        let key: String = "Expenses"
        guard let newExpensesData = try? JSONEncoder().encode(expenses) else { return }
        UserDefaults.standard.setValue(newExpensesData, forKey: key)
    }
    
}

struct AddView: View {
    
    @Environment(\.dismiss) var dismiss
    
     var expenses: Expenses
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0

    let types = ["Business", "Personal"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save") {
                    let item = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(item)
                    dismiss()
                }
            }
        }
    }
    
}


#Preview {
    ContentView()
}
