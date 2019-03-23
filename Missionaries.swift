public class Stack<T> {
    private var container: [T] = [T]()
    public var isEmpty: Bool { return container.isEmpty }
    public func push(_ thing: T) { container.append(thing) }
    public func pop() -> T { return container.removeLast() }
}

class Node<T> {
    let state: T
    let parent: Node?
    init(state: T, parent: Node?) {
        self.state = state
        self.parent = parent
    }
}

func dfs<StateType: Hashable>(initialState: StateType, goalTestFn: (StateType) -> Bool, successorFn: (StateType) -> [StateType]) -> Node<StateType>? {
    // frontier is where we've yet to go
    let frontier: Stack<Node<StateType>> = Stack<Node<StateType>>()
    frontier.push(Node(state: initialState, parent: nil))
    // explored is where we've been
    var explored: Set<StateType> = Set<StateType>()
    explored.insert(initialState)
    
    // keep going while there is more to explore
    while !frontier.isEmpty {
        let currentNode = frontier.pop()
        let currentState = currentNode.state
        // if we found the goal, we're done
        if goalTestFn(currentState) { return currentNode }
        // check where we can go next and haven't explored
        for child in successorFn(currentState) where !explored.contains(child) {
            explored.insert(child)
            frontier.push(Node(state: child, parent: currentNode))
        }
    }
    return nil // never found the goal
}

func nodeToPath<StateType>(_ node: Node<StateType>) -> [StateType] {
    var path: [StateType] = [node.state]
    var node = node // local modifiable copy of reference
    // work backwards from end to front
    while let currentNode = node.parent {
        path.insert(currentNode.state, at: 0)
        node = currentNode
    }
    return path
}

/// Missionaries and Cannibals

let maxNum = 3 // max number of missionaries or cannibals

struct MCState: Hashable, CustomStringConvertible {
    let missionaries: Int
    let cannibals: Int
    let boat: Bool
    var hashValue: Int { return missionaries * 10 + cannibals + (boat ? 1000 : 2000) }
    var description: String {
        let wm = missionaries // west bank missionaries
        let wc = cannibals // west bank cannibals
        let em = maxNum - wm // east bank missionaries
        let ec = maxNum - wc // east bank cannibals
        let description = "On the west bank there are \(wm) missionaries and \(wc) cannibals.\n" +
            "On the east bank there are \(em) missionaries and \(ec) cannibals.\n" +
        "The boat is on the \(boat ? "west" : "east") bank.\n"
        return description
    }
}

func ==(lhs: MCState, rhs: MCState) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func goalTestMC(state: MCState) -> Bool {
    return state == MCState(missionaries: 0, cannibals: 0, boat: false)
}

func isLegalMC(state: MCState) -> Bool {
    let wm = state.missionaries // west bank missionaries
    let wc = state.cannibals // west bank cannibals
    let em = maxNum - wm // east bank missionaries
    let ec = maxNum - wc // east bank cannibals
    // check there's not more cannibals than missionaries
    if wm < wc && wm > 0 { return false }
    if em < ec && em > 0 { return false }
    return true
}

func successorsMC(state: MCState) -> [MCState] {
    let wm = state.missionaries // west bank missionaries
    let wc = state.cannibals // west bank cannibals
    let em = maxNum - wm // east bank missionaries
    let ec = maxNum - wc // east bank cannibals
    var sucs: [MCState] = [MCState]() // next states
    
    if state.boat { // boat on west bank
        if wm > 1 {
            sucs.append(MCState(missionaries: wm - 2, cannibals: wc, boat: !state.boat))
        }
        if wm > 0 {
            sucs.append(MCState(missionaries: wm - 1, cannibals: wc, boat: !state.boat))
        }
        if wc > 1 {
            sucs.append(MCState(missionaries: wm, cannibals: wc - 2, boat: !state.boat))
        }
        if wc > 0 {
            sucs.append(MCState(missionaries: wm, cannibals: wc - 1, boat: !state.boat))
        }
        if (wc > 0) && (wm > 0){
            sucs.append(MCState(missionaries: wm - 1, cannibals: wc - 1, boat: !state.boat))
        }
    } else { // boat on east bank
        if em > 1 {
            sucs.append(MCState(missionaries: wm + 2, cannibals: wc, boat: !state.boat))
        }
        if em > 0 {
            sucs.append(MCState(missionaries: wm + 1, cannibals: wc, boat: !state.boat))
        }
        if ec > 1 {
            sucs.append(MCState(missionaries: wm, cannibals: wc + 2, boat: !state.boat))
        }
        if ec > 0 {
            sucs.append(MCState(missionaries: wm, cannibals: wc + 1, boat: !state.boat))
        }
        if (ec > 0) && (em > 0){
            sucs.append(MCState(missionaries: wm + 1, cannibals: wc + 1, boat: !state.boat))
        }
    }
    
    return sucs.filter{ isLegalMC(state: $0) }
}

func printMCSolution(path: [MCState]) {
    var oldState = path.first!
    print(oldState)
    for currentState in path[1..<path.count] {
        let wm = currentState.missionaries // west bank missionaries
        let wc = currentState.cannibals // west bank cannibals
        let em = maxNum - wm // east bank missionaries
        let ec = maxNum - wc // east bank cannibals
        if !currentState.boat {
            print("\(oldState.missionaries - wm) missionaries and \(oldState.cannibals - wc) cannibals moved from the west bank to the east bank.")
        } else {
            print("\(maxNum - oldState.missionaries - em) missionaries and \(maxNum - oldState.cannibals - ec) cannibals moved from the east bank to the west bank.")
        }
        print(currentState)
        oldState = currentState
    }
}

let startMC = MCState(missionaries: 3, cannibals: 3, boat: true)
if let solution = dfs(initialState: startMC, goalTestFn: goalTestMC, successorFn: successorsMC) {
    let path = nodeToPath(solution)
    printMCSolution(path: path)
}
