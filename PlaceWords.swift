import Foundation

/// Defines a constraint satisfaction problem. V is the type of the variables and D is the type of the domains.
public struct CSP <V: Hashable, D> {
    /// The variables in the CSP to be constrained.
    let variables: [V]
    /// The domains - every variable should have an associated domain.
    let domains: [V: [D]]
    /// The constraints on the variables.
    var constraints = Dictionary<V, [Constraint<V, D>]>()
    
    /// You should create the variables and domains before initializing the CSP.
    public init (variables: [V], domains:[V: [D]]) {
        self.variables = variables
        self.domains = domains
        for variable in variables {
            constraints[variable] = [Constraint]()
            if domains[variable] == nil {
                print("Error: Missing domain for variable \(variable).")
            }
        }
    }
    
    /// Add a constraint to the CSP. It will automatically be applied to all the variables it includes. It should only include variables actually in the CSP.
    ///
    /// - parameter constraint: The constraint to add.
    public mutating func addConstraint(_ constraint: Constraint<V, D>) {
        for variable in constraint.vars {
            if !variables.contains(variable) {
                print("Error: Could not find variable \(variable) from constraint \(constraint) in CSP.")
            }
            constraints[variable]?.append(constraint)
        }
    }
}

/// The base class of all constraints.
open class Constraint <V: Hashable, D> {
    /// All subclasses should override this method. It defines whether a constraint has successfully been satisfied
    /// - parameter assignment: Potential domain selections for variables that are part of the constraint.
    /// - returns: Whether the constraint is satisfied.
    func isSatisfied(assignment: Dictionary<V, D>) -> Bool {
        return true
    }
    /// The variables that make up the constraint.
    var vars: [V] { return [] }
}

/// the meat of the backtrack algorithm - a recursive depth first search
///
/// - parameter csp: The CSP to operate on.
/// - parameter assignment: Optionally, an already partially completed assignment.
/// - returns: the assignment (solution), or nil if none can be found
public func backtrackingSearch<V, D>(csp: CSP<V, D>, assignment: Dictionary<V, D> = Dictionary<V, D>()) -> Dictionary<V, D>?
{
    // assignment is complete if it has as many assignments as there are variables
    if assignment.count == csp.variables.count { return assignment } // base case
    
    // what are the unassigned variables?
    let unassigned = csp.variables.lazy.filter({ assignment[$0] == nil })
    
    // get the domain of the first unassigned variable
    if let variable: V = unassigned.first, let domain = csp.domains[variable] {
        // try each value in the domain
        for value in domain {
            var localAssignment = assignment
            localAssignment[variable] = value
            // if the value is consistent with the current assignment we continue
            if isConsistent(variable: variable, value: value, assignment: localAssignment, csp: csp) {
                // if as we go down the tree we get a complete assignment, return it
                if let result = backtrackingSearch(csp: csp, assignment: localAssignment) {
                    return result
                }
            }
        }
    }
    return nil  // no solution
}

/// check if the value assignment is consistent by checking all constraints of the variable
func isConsistent<V, D>(variable: V, value: D, assignment: Dictionary<V, D>, csp: CSP<V,D>) -> Bool {
    for constraint in csp.constraints[variable] ?? [] {
        if !constraint.isSatisfied(assignment: assignment) {
            return false
        }
    }
    return true
}

typealias Grid = [[Character]]

// A point on the grid
struct GridLocation: Hashable {
    let row: Int
    let col: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(row.hashValue)
        hasher.combine(col.hashValue)
    }
}
func == (lhs: GridLocation, rhs: GridLocation) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

// All the letters in our word search
let ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// randomly inserted with characters
func generateGrid(rows: Int, columns: Int) -> Grid {
    // initialize grid full of empty spaces
    var grid: Grid = Grid(repeating: [Character](repeating: " ", count: columns), count: rows)
    // replace spaces with random letters
    for row in 0..<rows {
        for col in 0..<columns {
            let loc = ALPHABET.index(ALPHABET.startIndex, offsetBy: Int(arc4random_uniform(UInt32(ALPHABET.count))))
            grid[row][col] = ALPHABET[loc]
        }
    }
    return grid
}

func printGrid(_ grid: Grid) {
    for i in 0..<grid.count {
        print(String(grid[i]))
    }
}

var grid = generateGrid(rows: 9, columns: 9)

func generateDomain(word: String, grid: Grid) -> [[GridLocation]] {
    var domain: [[GridLocation]] = [[GridLocation]]()
    let height = grid.count
    let width = grid[0].count
    let wordLength = word.count
    for row in 0..<height {
        for col in 0..<width {
            let columns = col...(col + wordLength)
            let rows = row...(row + wordLength)
            if (col + wordLength <= width) {
                // left to right
                domain.append(columns.map({GridLocation(row: row, col: $0)}))
                // diagonal towards bottom right
                if (row + wordLength <= height) {
                    domain.append(rows.map({GridLocation(row: $0, col: col + ($0 - row))}))
                }
            }
            if (row + wordLength <= height) {
                // top to bottom
                domain.append(rows.map({GridLocation(row: $0, col: col)}))
                // diagonal towards bottom left
                if (col - wordLength >= 0) {
                    domain.append(rows.map({GridLocation(row: $0, col: col - ($0 - row))}))
                }
            }
        }
    }
    return domain
}


final class WordSearchConstraint: Constraint <String, [GridLocation]> {
    let words: [String]
    final override var vars: [String] { return words }
    
    init(words: [String]) {
        self.words = words
    }
    
    override func isSatisfied(assignment: Dictionary<String, [GridLocation]>) -> Bool {
        if Set<GridLocation>(assignment.values.flatMap({$0})).count < assignment.values.flatMap({$0}).count {
            return false
        }
        
        return true
    }
}

let words: [String] = ["MATTHEW", "JOE", "MARY", "SARAH", "SALLY"]
var locations = Dictionary<String, [[GridLocation]]>()
for word in words {
    locations[word] = generateDomain(word: word, grid: grid)
}

var wordsearch = CSP<String, [GridLocation]>(variables: words, domains: locations)
wordsearch.addConstraint(WordSearchConstraint(words: words))
if let solution = backtrackingSearch(csp: wordsearch) {
    print("Find the following words in the crossword puzzle: \(words)")
    print()
    for (word, gridLocations) in solution {
        let gridLocs = arc4random_uniform(2) > 0 ? gridLocations : gridLocations.reversed() // randomly reverse word half the time
        for (index, letter) in word.enumerated() {
            let (row, col) = (gridLocs[index].row, gridLocations[index].col)
            grid[row][col] = letter
        }
    }
    printGrid(grid)
} else { print("Couldn't find solution!") }
