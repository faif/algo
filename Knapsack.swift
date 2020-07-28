import Foundation

/// Knapsack
struct Item {
    let name: String
    let weight: Int
    let value: Float
}

// originally based on Algorithms in C by Sedgewick, Second Edition, p 596
func knapsack(items: [Item], maxCapacity: Int) -> [Item] {
    //build up dynamic programming table
    var table: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: maxCapacity + 1), count: items.count + 1)  //initialize table - overshooting in size
    for (i, item) in items.enumerated() {
        for capacity in 1...maxCapacity {
            let previousItemsValue = table[i][capacity]
            if capacity >= item.weight { // item fits in knapsack
                let valueFreeingWeightForItem = table[i][capacity - item.weight]
                table[i + 1][capacity] = max(valueFreeingWeightForItem + item.value, previousItemsValue)  // only take if more valuable than previous combo
            } else { // no room for this item
                table[i + 1][capacity] = previousItemsValue //use prior combo
            }
        }
    }
    // figure out solution from table
    var solution: [Item] = [Item]()
    var capacity = maxCapacity
    for i in stride(from: items.count, to: 0, by: -1) { // work backwards
        if table[i - 1][capacity] != table[i][capacity] {  // did we use this item?
            solution.append(items[i - 1])
            capacity -= items[i - 1].weight  // if we used an item, remove its weight
        }
    }
    return solution
}

let items = [Item(name: "television", weight: 50, value: 500),
             Item(name: "candlesticks", weight: 2, value: 300),
             Item(name: "stereo", weight: 35, value: 400),
             Item(name: "laptop", weight: 3, value: 1000),
             Item(name: "food", weight: 15, value: 50),
             Item(name: "clothing", weight: 20, value: 800),
             Item(name: "jewelry", weight: 1, value: 4000),
             Item(name: "books", weight: 100, value: 300),
             Item(name: "printer", weight: 18, value: 30),
             Item(name: "refrigerator", weight: 200, value: 700),
             Item(name: "painting", weight: 10, value: 1000)]


let capacity = 35
let result = knapsack(items: items, maxCapacity: capacity)
print("==== knapsack solution for \(capacity)lb capacity ====")
for item in result {
    print("\(item.name), \(item.weight)lb, $\(item.value)")
}
