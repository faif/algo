let vtCities = ["Rutland", "Burlington", "White River Junction", "Bennington", "Brattleboro"]

let vtDistances = [
    "Rutland":
        ["Burlington": 67, "White River Junction": 46, "Bennington": 55, "Brattleboro": 75],
    "Burlington":
        ["Rutland": 67, "White River Junction": 91, "Bennington": 122, "Brattleboro": 153],
    "White River Junction":
        ["Rutland": 46, "Burlington": 91, "Bennington": 98, "Brattleboro": 65],
    "Bennington":
        ["Rutland": 55, "Burlington": 122, "White River Junction": 98, "Brattleboro": 40],
    "Brattleboro":
        ["Rutland": 75, "Burlington": 153, "White River Junction": 65, "Bennington": 40]
]

// backtracking permutations algorithm
func allPermutationsHelper<T>(contents: [T], permutations: inout [[T]], n: Int) {
    guard n > 0 else { permutations.append(contents); return }
    var tempContents = contents
    for i in 0..<n {
        tempContents.swapAt(i, n - 1) // move the element at i to the end
        // move everything else around, holding the end constant
        allPermutationsHelper(contents: tempContents, permutations: &permutations, n: n - 1)
        tempContents.swapAt(i, n - 1) // backtrack
    }
}

// find all of the permutations of a given array
func allPermutations<T>(_ original: [T]) -> [[T]] {
    var permutations = [[T]]()
    allPermutationsHelper(contents: original, permutations: &permutations, n: original.count)
    return permutations
}

// make complete paths for tsp
func tspPaths<T>(_ permutations: [[T]]) -> [[T]] {
    return permutations.map {
        if let first = $0.first {
            return ($0 + [first]) // append first to end
        } else {
            return [] // empty is just itself
        }
    }
}

func solveTSP<T>(cities: [T], distances: [T: [T: Int]]) -> (solution: [T], distance: Int) {
    let possiblePaths = tspPaths(allPermutations(cities)) // all potential paths
    var bestPath: [T] = [] // shortest path by distance
    var minDistance: Int = Int.max // distance of the shortest path
    for path in possiblePaths {
        if path.count < 2 { continue } // must be at least one city pair to calculate
        var distance = 0
        var last = path.first!
        for next in path[1..<path.count] { // add up all pair distances
            distance += distances[last]![next]!
            last = next
        }
        if distance < minDistance { // found a new best path
            minDistance = distance
            bestPath = path
        }
    }
    return (solution: bestPath, distance: minDistance)
}

print("TSP for visiting all cities in Vermont: \(vtCities)")
let vtTSP = solveTSP(cities: vtCities, distances: vtDistances)
print("The shortest path is \(vtTSP.solution) in \(vtTSP.distance) miles.")
