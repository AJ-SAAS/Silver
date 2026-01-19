import SwiftUI

struct HoldingsView: View {
    
    @StateObject private var vm = HoldingsViewModel()
    @StateObject private var priceService = PriceService() // for currentSpot
    
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if vm.isLoading {
                    ProgressView().scaleEffect(1.5)
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List {
                        Section(header: Text("My Stack")) {
                            ForEach(vm.holdings) { item in
                                VStack(alignment: .leading) {
                                    Text("\(item.type) x\(item.quantity)")
                                        .font(.headline)
                                    
                                    Text("Weight: \(item.totalWeight, specifier: "%.2f") oz")
                                        .font(.subheadline)
                                    
                                    Text("Current Value: $\(item.currentValue(currentSpot: priceService.currentSpot), specifier: "%.2f")")
                                        .font(.subheadline)
                                    
                                    if let pl = item.unrealizedPL(currentSpot: priceService.currentSpot) {
                                        Text("Unrealized P/L: $\(pl, specifier: "%.2f")")
                                            .foregroundColor(pl >= 0 ? .green : .red)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                Task {
                                    for index in indexSet {
                                        await vm.deleteItem(vm.holdings[index])
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
                
                // Totals
                VStack(spacing: 8) {
                    Text("Total Stack Value: $\(vm.totalStackValue(currentSpot: priceService.currentSpot), specifier: "%.2f")")
                        .bold()
                    Text("Total Ounces: \(vm.totalOunces(), specifier: "%.2f")")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Add button
                Button(action: { showAddSheet.toggle() }) {
                    Text("Add Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("My Holdings")
            .sheet(isPresented: $showAddSheet) {
                AddItemView { newItem in
                    Task { await vm.addItem(newItem) }
                    showAddSheet = false
                }
            }
            .task {
                await vm.loadHoldings()
            }
        }
    }
}
