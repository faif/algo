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

final class SendMoreMoneyConstraint: Constraint <Character, Int> {
    let letters: [Character]
    final override var vars: [Character] { return letters }
    init(variables: [Character]) {
        letters = variables
    }
    
    override func isSatisfied(assignment: Dictionary<Character, Int>) -> Bool {
        // if there are duplicate values then it's not correct
        let d = Set<Int>(assignment.values)
        if d.count < assignment.count {
            return false
        }
        
        // if all variables have been assigned, check if it adds up correctly
        if assignment.count == letters.count {
            if let s = assignment["S"], let e = assignment["E"], let n = assignment["N"], let d = assignment["D"], let m = assignment["M"], let o = assignment["O"], let r = assignment["R"], let y = assignment["Y"] {
                let send: Int = s * 1000 + e * 100 + n * 10 + d
                let more: Int = m * 1000 + o * 100 + r * 10 + e
                let money: Int = m * 10000 + o * 1000 + n * 100 + e * 10 + y
                if (send + more) == money {
                    return true // answer found
                }
            }
            return false // this full assignment doesn't work
        }
        
        // until we have all of the variables assigned, the assignment is valid
        return true
    }
}

func showWordAsNumber(word: Array<String>, mapping: Dictionary<Character, Int>) {
    for letter in word {
         if let value = mapping[Character(letter)] {
            print(value, terminator:"")
        }
    }
}

let letters: [Character] = ["S", "E", "N", "D", "M", "O", "R", "Y"]
var possibleDigits = Dictionary<Character, [Int]>()
for letter in letters {
    possibleDigits[letter] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
}

var smmcsp = CSP<Character, Int>(variables: letters, domains: possibleDigits)
let smmcon = SendMoreMoneyConstraint(variables: letters)
smmcsp.addConstraint(smmcon)

print("Calculating [SEND + MORE = MONEY]...")
if let solution = backtrackingSearch(csp: smmcsp) {
    showWordAsNumber(word: ["S", "E", "N", "D"], mapping: solution)
    print(" + ", terminator:"")
    showWordAsNumber(word: ["M", "O", "R", "E"], mapping: solution)
    print(" = ", terminator:"")
    showWordAsNumber(word: ["M", "O", "N", "E", "Y"], mapping: solution)
    print()
} else { print("Couldn't find solution!") }


