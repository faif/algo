import Foundation

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

final class MapColoringConstraint: Constraint <String, String> {
    let place1: String
    let place2: String
    final override var vars: [String] { return [place1, place2] }
    
    init(place1: String, place2: String) {
        self.place1 = place1
        self.place2 = place2
    }
    
    override func isSatisfied(assignment: Dictionary<String, String>) -> Bool {
        if hasNoColor(assignment: assignment, place: place1) ||
            hasNoColor(assignment: assignment, place: place2) {
            return true
        }
        return differentColors(assignment: assignment, place1: place1, place2: place2)
    }
    
    func hasNoColor(assignment: Dictionary<String, String>, place: String) -> Bool {
        return assignment[place] == nil
    }
    
    func differentColors(assignment: Dictionary<String, String>, place1: String, place2: String) -> Bool {
        return assignment[place1] != assignment[place2]
    }
}

let variables = ["Western Australia", "Northern Territory", "South Australia", "Queensland", "New South Wales", "Victoria", "Tasmania"]
var domains = Dictionary<String, [String]>()
for variable in variables {
    domains[variable] = ["r", "g", "b"]
}

var csp = CSP<String, String>(variables: variables, domains: domains)
csp.addConstraint(MapColoringConstraint(place1: "Western Australia", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Western Australia", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "South Australia", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland",
                                        place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland", place2: "New South Wales"))
csp.addConstraint(MapColoringConstraint(place1: "New South Wales", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Victoria", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Victoria", place2: "New South Wales"))

if let solution = backtrackingSearch(csp: csp) {
    print(solution)
} else { print("Couldn't find solution!") }

