import Foundation

let phoneMapping: [Character: [Character]] = ["1": ["1"], "2": ["a", "b", "c"], "3": ["d", "e", "f"],
                                              "4": ["g", "h", "i"], "5": ["j", "k", "l"], "6": ["m", "n", "o"],
                                              "7": ["p", "q", "r", "s"], "8": ["t", "u", "v"],
                                              "9": ["w", "x", "y", "z"], "0": ["0"]]

// return all of the possible characters combos, given a mapping, for a given number
func stringToPossibilities(_ s: String, mapping: [Character: [Character]]) -> [[Character]]{
    let possibilities = s.compactMap{ mapping[$0] }
    return combineAllPossibilities(possibilities)
}

// takes a set of possible characters for each position and finds all possible permutations
func combineAllPossibilities(_ possibilities: [[Character]]) -> [[Character]] {
    guard let possibility = possibilities.first else { return [[]] }
    var permutations: [[Character]] = possibility.map { [$0] } // turn each into an array
    for possibility in possibilities[1..<possibilities.count] where possibility != [] {
        let toRemove = permutations.count // temp
        for permutation in permutations {
            for c in possibility { // try adding every letter
                var newPermutation: [Character] = permutation // need a mutable copy
                newPermutation.append(c) // add character on the end
                permutations.append(newPermutation) // new combo ready
            }
        }
        permutations.removeFirst(toRemove) // remove combos missing new last letter
    }
    return permutations
}

let telephoneNumber = "1440787"
let permutations = stringToPossibilities(telephoneNumber, mapping: phoneMapping)
print("Possible mnemonics for tel. \(telephoneNumber): \(permutations)")
