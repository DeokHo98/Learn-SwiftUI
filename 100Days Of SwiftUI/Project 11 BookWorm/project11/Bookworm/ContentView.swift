//
//  ContentView.swift
//  Bookworm
//
//  Created by Paul Hudson on 16/11/2023.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Query(sort: [SortDescriptor(\Book.title),
                  SortDescriptor(\Book.rating, order: .reverse)]) private var books: [Book]
    @State private var showingAddScreen = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink(value: book) {
                        HStack {
                            Text("\(book.rating)")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    deleteBooks(at: indexSet)
                })
            }
            .navigationTitle("Bookworm")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Book", systemImage: "plus") {
                        showingAddScreen.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddBookView()
            }
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            let book = books[offset]
            modelContext.delete(book)
            try? modelContext.save()
        }
    }
}





#Preview {
    ContentView()
}

