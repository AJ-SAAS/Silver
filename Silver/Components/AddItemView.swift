import SwiftUI

struct AddItemView: View {
    
    @State private var type = "Coin"
    @State private var quantity: String = ""
    @State private var weightPerUnit: String = ""
    @State private var purchasePricePerOz: String = ""
    @State private var premium: String = ""
    
    @State private var selectedWeightPreset = "1 oz"
    let commonWeights = ["1 oz", "10 oz", "100 oz", "Custom"]
    
    var onSave: (SilverItem) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Type") {
                    Picker("Type", selection: $type) {
                        Text("Coin").tag("Coin")
                        Text("Bar").tag("Bar")
                        Text("Round").tag("Round")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Quantity & Weight") {
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { quantity = $0.filter { "0123456789.".contains($0) } }
                    
                    Picker("Weight per unit", selection: $selectedWeightPreset) {
                        ForEach(commonWeights, id: \.self) { weight in
                            Text(weight).tag(weight)
                        }
                    }
                    
                    if selectedWeightPreset == "Custom" {
                        TextField("Custom weight (oz)", text: $weightPerUnit)
                            .keyboardType(.decimalPad)
                            .onChange(of: weightPerUnit) { weightPerUnit = $0.filter { "0123456789.".contains($0) } }
                    } else {
                        Text(selectedWeightPreset)
                            .foregroundColor(.gray)
                    }
                }
                
                Section("Purchase Info (optional)") {
                    TextField("Purchase price per oz", text: $purchasePricePerOz)
                        .keyboardType(.decimalPad)
                        .onChange(of: purchasePricePerOz) { purchasePricePerOz = $0.filter { "0123456789.".contains($0) } }
                    
                    TextField("Premium %", text: $premium)
                        .keyboardType(.decimalPad)
                        .onChange(of: premium) { premium = $0.filter { "0123456789.".contains($0) } }
                }
            }
            .navigationTitle("Add Holding")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { }
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let q = Double(quantity), q > 0 else { return false }
        let w: Double?
        if selectedWeightPreset == "Custom" {
            w = Double(weightPerUnit)
        } else {
            w = Double(selectedWeightPreset.split(separator: " ")[0])
        }
        return w != nil && w! > 0
    }
    
    private func saveItem() {
        guard let q = Double(quantity),
              let w = selectedWeightPreset == "Custom" ? Double(weightPerUnit) : Double(selectedWeightPreset.split(separator: " ")[0]),
              q > 0, w > 0 else { return }
        
        let p = Double(purchasePricePerOz) ?? nil
        let pr = Double(premium) ?? nil
        
        let item = SilverItem(
            type: type,
            quantity: q,
            weightPerUnit: w,
            purchasePricePerOz: p,
            premiumPaid: pr
        )
        
        onSave(item)
    }
}
