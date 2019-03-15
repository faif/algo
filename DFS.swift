import Foundation

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

// the start is fixed, but the goal position is random
let start = MazeLocation(row: 0, col: 0)
let rows = 10, columns = 10
let goalRow = Int.random(in: 1 ..< rows), goalCol = Int.random(in: 0 ..< columns)
let goal = MazeLocation(row: goalRow, col: goalCol)

var maze = generateMaze(rows: rows, columns: columns, sparseness: 0.3, start: start, goal: goal)

func goalTest(ml: MazeLocation) -> Bool {
    return ml == goal
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

if let solution = dfs(initialState: start, goalTestFn: goalTest, successorFn: successorsForMaze(maze)) {
    let path = nodeToPath(solution)
    markMaze(maze: &maze, path: path, start: start, goal: goal)
    print("== DFS solution ==")
    printMaze(maze: maze)
}
else {
    print("No DFS solution found")
}
