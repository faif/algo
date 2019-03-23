import Foundation

/// A PriorityQueue takes objects to be pushed of any type that implements Comparable.
/// It will pop the objects in the order that they would be sorted. A pop() or a push()
/// can be accomplished in O(lg n) time. It can be specified whether the objects should
/// be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
/// at the time of initialization.
public struct PriorityQueue<T: Comparable> {
    
    fileprivate var heap = [T]()
    private let ordered: (T, T) -> Bool
    
    public init(ascending: Bool = false, startingValues: [T] = []) {
        self.init(order: ascending ? { $0 > $1 } : { $0 < $1 }, startingValues: startingValues)
    }
    
    /// Creates a new PriorityQueue with the given ordering.
    ///
    /// - parameter order: A function that specifies whether its first argument should
    ///                    come after the second argument in the PriorityQueue.
    /// - parameter startingValues: An array of elements to initialize the PriorityQueue with.
    public init(order: @escaping (T, T) -> Bool, startingValues: [T] = []) {
        ordered = order
        
        // Based on "Heap construction" from Sedgewick p 323
        heap = startingValues
        var i = heap.count/2 - 1
        while i >= 0 {
            sink(i)
            i -= 1
        }
    }
    
    /// How many elements the Priority Queue stores
    public var count: Int { return heap.count }
    
    /// true if and only if the Priority Queue is empty
    public var isEmpty: Bool { return heap.isEmpty }
    
    /// Add a new element onto the Priority Queue. O(lg n)
    ///
    /// - parameter element: The element to be inserted into the Priority Queue.
    public mutating func push(_ element: T) {
        heap.append(element)
        swim(heap.count - 1)
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// - returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    public mutating func pop() -> T? {
        
        if heap.isEmpty { return nil }
        if heap.count == 1 { return heap.removeFirst() }  // added for Swift 2 compatibility
        // so as not to call swap() with two instances of the same location
        heap.swapAt(0, heap.count - 1)
        let temp = heap.removeLast()
        sink(0)
        
        return temp
    }
    
    
    /// Removes the first occurence of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove the first occurrence of.
    public mutating func remove(_ item: T) {
        if let index = heap.index(of: item) {
            heap.swapAt(index, heap.count - 1)
            heap.removeLast()
            swim(index)
            sink(index)
        }
    }
    
    /// Removes all occurences of a particular item. Finds it by value comparison using ==. O(n)
    /// Silently exits if no occurrence found.
    ///
    /// - parameter item: The item to remove.
    public mutating func removeAll(_ item: T) {
        var lastCount = heap.count
        remove(item)
        while (heap.count < lastCount) {
            lastCount = heap.count
            remove(item)
        }
    }
    
    /// Get a look at the current highest priority item, without removing it. O(1)
    ///
    /// - returns: The element with the highest priority in the PriorityQueue, or nil if the PriorityQueue is empty.
    public func peek() -> T? {
        return heap.first
    }
    
    /// Eliminate all of the elements from the Priority Queue.
    public mutating func clear() {
        heap.removeAll(keepingCapacity: false)
    }
    
    // Based on example from Sedgewick p 316
    private mutating func sink(_ index: Int) {
        var index = index
        while 2 * index + 1 < heap.count {
            
            var j = 2 * index + 1
            
            if j < (heap.count - 1) && ordered(heap[j], heap[j + 1]) { j += 1 }
            if !ordered(heap[index], heap[j]) { break }
            
            heap.swapAt(index, j)
            index = j
        }
    }
    
    // Based on example from Sedgewick p 316
    private mutating func swim(_ index: Int) {
        var index = index
        while index > 0 && ordered(heap[(index - 1) / 2], heap[index]) {
            heap.swapAt((index - 1) / 2, index)
            index = (index - 1) / 2
        }
    }
}

// MARK: - GeneratorType
extension PriorityQueue: IteratorProtocol {
    
    public typealias Element = T
    mutating public func next() -> Element? { return pop() }
}

// MARK: - SequenceType
extension PriorityQueue: Sequence {
    
    public typealias Iterator = PriorityQueue
    public func makeIterator() -> Iterator { return self }
}

// MARK: - CollectionType
extension PriorityQueue: Collection {
    
    public typealias Index = Int
    
    public var startIndex: Int { return heap.startIndex }
    public var endIndex: Int { return heap.endIndex }
    
    public subscript(i: Int) -> T { return heap[i] }
    
    public func index(after i: PriorityQueue.Index) -> PriorityQueue.Index {
        return heap.index(after: i)
    }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension PriorityQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String { return heap.description }
    public var debugDescription: String { return heap.debugDescription }
}

enum Cell: Character {
    case Empty = "O"
    case Blocked = "X"
    case Start = "S"
    case Goal = "G"
    case Path = "P"
}

typealias Maze = [[Cell]]
srand48(time(nil)) // seed random number generator

struct MazeLocation: Hashable {
    let row: Int, col: Int
}

func == (lhs: MazeLocation, rhs: MazeLocation) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

// sparseness is the approximate percentage of walls represented
// as a number between 0 and 1
func generateMaze(rows: Int, columns: Int, sparseness: Double, start: MazeLocation, goal: MazeLocation) -> Maze {
    // initialize maze full of empty spaces
    var maze: Maze = Maze(repeating: [Cell](repeating: .Empty, count: columns), count: rows)
    // put walls in
    for row in 0..<rows {
        for col in 0..<columns {
            if drand48() < sparseness { // chance of wall
                maze[row][col] = .Blocked
            }
        }
    }
    maze[start.row][start.col] = .Start
    maze[goal.row][goal.col] = .Goal
    return maze
}

func printMaze(maze: Maze) {
    for i in 0..<maze.count {
        print(String(maze[i].map{ $0.rawValue }))
    }
}

func successorsForMaze(_ maze: Maze) -> (MazeLocation) -> [MazeLocation] {
    func successors(ml: MazeLocation) -> [MazeLocation] { // no  diagonals
        var newMLs: [MazeLocation] = [MazeLocation]()
        // check top
        if (ml.row + 1 < maze.count) && (maze[ml.row + 1][ml.col] != .Blocked) {
            newMLs.append(MazeLocation(row: ml.row + 1, col: ml.col))
        }
        // check bottom
        if (ml.row - 1 >= 0) && (maze[ml.row - 1][ml.col] != .Blocked) {
            newMLs.append(MazeLocation(row: ml.row - 1, col: ml.col))
        }
        // check right
        if (ml.col + 1 < maze[0].count) && (maze[ml.row][ml.col + 1] != .Blocked) {
            newMLs.append(MazeLocation(row: ml.row, col: ml.col + 1))
        }
        // check left
        if (ml.col - 1 >= 0) && (maze[ml.row][ml.col - 1] != .Blocked) {
            newMLs.append(MazeLocation(row: ml.row, col: ml.col - 1))
        }
        
        return newMLs
    }
    return successors
}

class Node<T>: Comparable, Hashable {
    let state: T
    let parent: Node?
    let cost: Float
    let heuristic: Float
    init(state: T, parent: Node?, cost: Float = 0.0, heuristic: Float = 0.0) {
        self.state = state
        self.parent = parent
        self.cost = cost
        self.heuristic = heuristic
    }
    
    var hashValue: Int { return Int(cost + heuristic) }
}

func < <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return (lhs.cost + lhs.heuristic) < (rhs.cost + rhs.heuristic)
}

func == <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return lhs === rhs
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

func markMaze(maze: inout Maze, path: [MazeLocation], start: MazeLocation, goal: MazeLocation) {
    for ml in path {
        maze[ml.row][ml.col] = .Path
    }
    maze[start.row][start.col] = .Start
    maze[goal.row][goal.col] = .Goal
}

// the start is fixed, but the goal position is random
let start = MazeLocation(row: 0, col: 0)
let rows = 10, columns = 10
let goalRow = Int.random(in: 1 ..< rows), goalCol = Int.random(in: 0 ..< columns)
let goal = MazeLocation(row: goalRow, col: goalCol)

var maze = generateMaze(rows: rows, columns: columns, sparseness: 0.3, start: start, goal: goal)

func goalTest(ml: MazeLocation) -> Bool {
    return ml == goal
}

func manhattanDistance(ml: MazeLocation) -> Float {
    let xdist = abs(ml.col - goal.col)
    let ydist = abs(ml.row - goal.row)
    return Float(xdist + ydist)
}

//a*
//returns a node containing the goal state
func astar<StateType: Hashable>(initialState: StateType, goalTestFn: (StateType) -> Bool, successorFn: (StateType) -> [StateType], heuristicFn: (StateType) -> Float) -> Node<StateType>? {
    // frontier is where we've yet to go
    var frontier: PriorityQueue<Node<StateType>> = PriorityQueue<Node<StateType>>(ascending: true, startingValues: [Node(state: initialState, parent: nil, cost: 0, heuristic: heuristicFn(initialState))])
    // explored is where we've been
    var explored = Dictionary<StateType, Float>()
    explored[initialState] = 0
    // keep going while there is more to explore
    while let currentNode = frontier.pop() {
        let currentState = currentNode.state
        // if we found the goal, we're done
        if goalTestFn(currentState) { return currentNode }
        // check where we can go next and haven't explored
        for child in successorFn(currentState) {
            let newcost = currentNode.cost + 1  // assumes a grid, there should be a cost function for more sophisticated applications
            if (explored[child] == nil) || (explored[child]! > newcost) {
                explored[child] = newcost
                frontier.push(Node(state: child, parent: currentNode, cost: newcost, heuristic: heuristicFn(child)))
            }
        }
    }
    return nil // never found the goal
}

print()
print("== Legend ==")
print("S = Start")
print("O = Empty")
print("X = Blocked")
print("P = Path")
print("G = Goal")
print()

print("== Generated maze ==")
printMaze(maze: maze)
print()

if let solution = astar(initialState: start, goalTestFn: goalTest, successorFn: successorsForMaze(maze),
                        heuristicFn: manhattanDistance) {
    let path = nodeToPath(solution)
    markMaze(maze: &maze, path: path, start: start, goal: goal)
    print("== A* solution ==")
    printMaze(maze: maze)
}
else {
    print("No A* solution found")
}
