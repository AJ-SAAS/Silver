import SwiftUI

struct AddItemView: View {
    
    @State private var type = "Coin"
    @State private var quantity = ""
    @State private var weight = ""
    @State private var purchasePrice = ""
    @State private var premium = ""
    
    var onSave: (SilverItem) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Type", selection: $type) {
                    Text("Coin").tag("Coin")
                    Text("Bar").tag("Bar")
                    Text("Round").tag("Round")
                }
                
                TextField("Quantity", text: $quantity)
                    .keyboardType(.decimalPad)
                
                TextField("Weight per unit (oz)", text: $weight)
                    .keyboardType(.decimalPad)
                
                TextField("Purchase price per oz (optional)", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                
                TextField("Premium % (optional)", text: $premium)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let q = Double(quantity),
                              let w = Double(weight) else { return }
                        let p = Double(purchasePrice)
                        let pr = Double(premium)
                        let item = SilverItem(type: type, quantity: q, weightPerUnit: w, purchasePricePerOz: p, premiumPaid: pr)
                        onSave(item)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { }
                }
            }
        }
    }
}
