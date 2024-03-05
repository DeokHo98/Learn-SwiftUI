//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Paul Hudson on 09/11/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var order = Order()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("케이크 종류를 선택하세요", selection: $order.type) {
                        ForEach(Order.types, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Stepper("개수: \(order.quantity)",
                            value: $order.quantity, in: 0...20)
                }
                
                Section {
                    Toggle("스페셜 오더하기", isOn: $order.specialRequestEnabled)
                        .disabled(order.quantity <= 0)
                    
                    Toggle("frosting 추가", isOn: $order.extraProsting)
                        .disabled(!order.specialRequestEnabled)
                       
                    Toggle("sprinkles 추가", isOn: $order.addSprinkles).disabled(
                        !order.specialRequestEnabled)
                }
                
                Section {
                    NavigationLink("주문 상세") {
                        AddressView(order: order)
                    }
                    .disabled(order.quantity <= 0)
                }
            }
            .navigationTitle("컵케이크 코너")
        }
    }
}

struct AddressView: View {
    @State var order: Order
    
    var hasValidAddress: Bool {
        return order.name.isEmpty || order.streetAddress.isEmpty || order.city.isEmpty || order.zip.isEmpty
    }

    var body: some View {
        Form {
            Section {
                TextField("이름", text: $order.name)
                TextField("주소", text: $order.streetAddress)
                TextField("도시", text: $order.city)
                TextField("우편번호", text: $order.zip)
            }

            Section {
                NavigationLink("주문") {
                    CheckoutView(order: order)
                }
                .disabled(hasValidAddress)
            }
        }
        .navigationTitle("주문 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CheckoutView: View {
    var order: Order
    
    var cost: Double {
        var cost = Double(order.quantity) * 2
        
        if order.extraProsting {
            cost += Double(order.quantity)
        }
        
        if order.addSprinkles {
            cost += Double(order.quantity) / 2
        }
        
        return cost
    }
    
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false

    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string:  "https://hws.dev/img/cupcakes@3x.jpg")) {
                    $0.resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("주문 총금액은 \(cost, format: .currency(code: "USD")) 입니다.")
                    .font(.title)
                Button("주문") {
                    Task {
                        await placeOrder()
                    }
                }
                .padding()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("주문")
        .navigationBarTitleDisplayMode(.inline)
        .alert("알림",
               isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
    }
    
    private func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(order) else { return }
        print("debug \(encoded)")
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        let str = String(decoding: encoded, as: UTF8.self)
        print("debug \(str)")
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "당신의 주문 \(order.type) 컵케이크 \(decodedOrder.quantity)개가 곧 배달갑니다!"
            showingConfirmation = true
        } catch {
            confirmationMessage = error.localizedDescription
            showingConfirmation = true
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}

#Preview {
    AddressView(order: Order())
}

#Preview {
    ContentView()
}
