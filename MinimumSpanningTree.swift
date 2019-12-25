public protocol Edge: CustomStringConvertible {
    var u: Int { get set } // index of the "from" vertex
    var v: Int { get set } // index of the "to" vertex
    var reversed: Edge { get }
}

protocol Graph: class, CustomStringConvertible {
    associatedtype VertexType: Equatable
    associatedtype EdgeType: Edge
    var vertices: [VertexType] { get set }
    var edges: [[EdgeType]] { get set }
}

extension Graph {
    /// How many vertices are in the graph?
    public var vertexCount: Int { return vertices.count }
    
    /// How many edges are in the graph?
    public var edgeCount: Int { return edges.joined().count }
    
    /// Get a vertex by its index.
    ///
    /// - parameter index: The index of the vertex.
    /// - returns: The vertex at i.
    public func vertexAtIndex(_ index: Int) -> VertexType {
        return vertices[index]
    }
    
    /// Find the first occurence of a vertex if it exists.
    ///
    /// - parameter vertex: The vertex you are looking for.
    /// - returns: The index of the vertex. Return nil if it can't find it.
    public func indexOfVertex(_ vertex: VertexType) -> Int? {
        if let i = vertices.firstIndex(of: vertex) {
            return i
        }
        return nil
    }
    
    /// Find all of the neighbors of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the neighbors of.
    /// - returns: An array of the neighbor vertices.
    public func neighborsForIndex(_ index: Int) -> [VertexType] {
        return edges[index].map({self.vertices[$0.v]})
    }
    
    /// Find all of the neighbors of a given Vertex.
    ///
    /// - parameter vertex: The vertex to find the neighbors of.
    /// - returns: An optional array of the neighbor vertices.
    public func neighborsForVertex(_ vertex: VertexType) -> [VertexType]? {
        if let i = indexOfVertex(vertex) {
            return neighborsForIndex(i)
        }
        return nil
    }
    
    /// Find all of the edges of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the children of.
    public func edgesForIndex(_ index: Int) -> [EdgeType] {
        return edges[index]
    }
    
    /// Find all of the edges of a given vertex.
    ///
    /// - parameter vertex: The vertex to find the edges of.
    public func edgesForVertex(_ vertex: VertexType) -> [EdgeType]? {
        if let i = indexOfVertex(vertex) {
            return edgesForIndex(i)
        }
        return nil
    }
    
    /// Add a vertex to the graph.
    ///
    /// - parameter v: The vertex to be added.
    /// - returns: The index where the vertex was added.
    public func addVertex(_ v: VertexType) -> Int {
        vertices.append(v)
        edges.append([EdgeType]())
        return vertices.count - 1
    }
    
    /// Add an edge to the graph.
    ///
    /// - parameter e: The edge to add.
    public func addEdge(_ e: EdgeType) {
        edges[e.u].append(e)
        edges[e.v].append(e.reversed as! EdgeType)
    }
}


/// This protocol is needed for Dijkstra's algorithm - we need weights in weighted graphs
/// to be able to be added together
public protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Summable {}
extension Double: Summable {}
extension Float: Summable {}

/// A weighted edge, who's weight subscribes to Comparable.
open class WeightedEdge<W: Comparable & Summable>: Edge, Comparable {
    public var u: Int
    public var v: Int
    public let weight: W
    
    public var reversed: Edge {
        return WeightedEdge(u: v, v: u, weight: weight)
    }
    
    public init(u: Int, v: Int, weight: W) {
        self.weight = weight
        self.u = u
        self.v = v
    }
    
    //Implement CustomStringConvertible protocol
    public var description: String {
        return "\(u) <\(weight)> \(v)"
    }
    
    //MARK: Operator Overloads for Comparable
    static public func == <W>(lhs: WeightedEdge<W>, rhs: WeightedEdge<W>) -> Bool {
        return lhs.u == rhs.u && lhs.v == rhs.v && lhs.weight == rhs.weight
    }
    
    static public func < <W>(lhs: WeightedEdge<W>, rhs: WeightedEdge<W>) -> Bool {
        return lhs.weight < rhs.weight
    }
}

/// A subclass of Graph that has convenience methods for adding and removing WeightedEdges. All added Edges should have the same generic Comparable type W as the WeightedGraph itself.
open class WeightedGraph<V: Equatable & Hashable, W: Comparable & Summable>: Graph {
    var vertices: [V] = [V]()
    var edges: [[WeightedEdge<W>]] = [[WeightedEdge<W>]]() //adjacency lists
    
    public init() {
    }
    
    public init(vertices: [V]) {
        for vertex in vertices {
            _ = self.addVertex(vertex)
        }
    }
    
    /// Find all of the neighbors of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the neighbors of.
    /// - returns: An array of tuples including the vertices as the first element and the weights as the second element.
    public func neighborsForIndexWithWeights(_ index: Int) -> [(V, W)] {
        var distanceTuples: [(V, W)] = [(V, W)]()
        for edge in edges[index] {
            distanceTuples += [(vertices[edge.v], edge.weight)]
        }
        return distanceTuples
    }
    
    /// This is a convenience method that adds a weighted edge.
    ///
    /// - parameter from: The starting vertex's index.
    /// - parameter to: The ending vertex's index.
    /// - parameter weight: the Weight of the edge to add.
    public func addEdge(from: Int, to: Int, weight:W) {
        addEdge(WeightedEdge<W>(u: from, v: to, weight: weight))
    }
    
    /// This is a convenience method that adds a weighted edge between the first occurence of two vertices. It takes O(n) time.
    ///
    /// - parameter from: The starting vertex.
    /// - parameter to: The ending vertex.
    /// - parameter weight: the Weight of the edge to add.
    public func addEdge(from: V, to: V, weight: W) {
        if let u = indexOfVertex(from) {
            if let v = indexOfVertex(to) {
                addEdge(WeightedEdge<W>(u: u, v: v, weight:weight))
            }
        }
    }
    
    //Implement Printable protocol
    public var description: String {
        var d: String = ""
        for i in 0..<vertices.count {
            d += "\(vertices[i]) -> \(neighborsForIndexWithWeights(i))\n"
        }
        return d
    }
}

let cityGraph2: WeightedGraph<String, Int> = WeightedGraph<String, Int>(vertices: ["Seattle", "San Francisco", "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston", "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit", "Philadelphia", "Washington"])

cityGraph2.addEdge(from: "Seattle", to: "Chicago", weight: 1737)
cityGraph2.addEdge(from: "Seattle", to: "San Francisco", weight: 678)
cityGraph2.addEdge(from: "San Francisco", to: "Riverside", weight: 386)
cityGraph2.addEdge(from: "San Francisco", to: "Los Angeles", weight: 348)
cityGraph2.addEdge(from: "Los Angeles", to: "Riverside", weight: 50)
cityGraph2.addEdge(from: "Los Angeles", to: "Phoenix", weight: 357)
cityGraph2.addEdge(from: "Riverside", to: "Phoenix", weight: 307)
cityGraph2.addEdge(from: "Riverside", to: "Chicago", weight: 1704)
cityGraph2.addEdge(from: "Phoenix", to: "Dallas", weight: 887)
cityGraph2.addEdge(from: "Phoenix", to: "Houston", weight: 1015)
cityGraph2.addEdge(from: "Dallas", to: "Chicago", weight: 805)
cityGraph2.addEdge(from: "Dallas", to: "Atlanta", weight: 721)
cityGraph2.addEdge(from: "Dallas", to: "Houston", weight: 225)
cityGraph2.addEdge(from: "Houston", to: "Atlanta", weight: 702)
cityGraph2.addEdge(from: "Houston", to: "Miami", weight: 968)
cityGraph2.addEdge(from: "Atlanta", to: "Chicago", weight: 588)
cityGraph2.addEdge(from: "Atlanta", to: "Washington", weight: 543)
cityGraph2.addEdge(from: "Atlanta", to: "Miami", weight: 604)
cityGraph2.addEdge(from: "Miami", to: "Washington", weight: 923)
cityGraph2.addEdge(from: "Chicago", to: "Detroit", weight: 238)
cityGraph2.addEdge(from: "Detroit", to: "Boston", weight: 613)
cityGraph2.addEdge(from: "Detroit", to: "Washington", weight: 396)
cityGraph2.addEdge(from: "Detroit", to: "New York", weight: 482)
cityGraph2.addEdge(from: "Boston", to: "New York", weight: 190)
cityGraph2.addEdge(from: "New York", to: "Philadelphia", weight: 81)
cityGraph2.addEdge(from: "Philadelphia", to: "Washington", weight: 123)

// Find the total weight of an array of weighted edges
/// - parameter edges The edge array to find the total weight of.
public func totalWeight<W>(_ edges: [WeightedEdge<W>]) -> W? {
    guard let firstWeight = edges.first?.weight else { return nil }
    return edges.dropFirst().reduce(firstWeight) { (result, next) -> W in
        return result + next.weight
    }
}

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
        if let index = heap.firstIndex(of: item) {
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


/// Extensions to WeightedGraph for building a Minimum-Spanning Tree (MST)
public extension WeightedGraph {
    typealias WeightedPath = [WeightedEdge<W>]
    // Citation: Based on Algorithms 4th Edition by Sedgewick, Wayne pg 619
    
    /// Find the minimum spanning tree in a weighted graph. This is the set of edges
    /// that touches every vertex in the graph and is of minimal combined weight. This function
    /// uses Jarnik's Algorithm (aka Prim's Algorithm) and so assumes the graph has
    /// undirected edges. For a graph with directed edges, the result may be incorrect. Also,
    /// if the graph is not fully connected, the tree will only span the connected component from which
    /// the starting vertex belongs.
    ///
    /// - parameter start: The index of the vertex to start creating the MST from.
    /// - returns: An array of WeightedEdges containing the minimum spanning tree, or nil if the starting vertex is invalid. If there are is only one vertex connected to the starting vertex, an empty list is returned.
    func mst(start: Int = 0) -> WeightedPath? {
        if start > (vertexCount - 1) || start < 0 { return nil }
        var result: [WeightedEdge<W>] = [WeightedEdge<W>]() // the final MST goes in here
        var pq: PriorityQueue<WeightedEdge<W>> = PriorityQueue<WeightedEdge<W>>(ascending: true) // minPQ
        var visited: [Bool] = Array<Bool>(repeating: false, count: vertexCount) // already been to these
        
        func visit(_ index: Int) {
            visited[index] = true // mark as visited
            for edge in edgesForIndex(index) { // add all edges coming from here to pq
                if !visited[edge.v] { pq.push(edge) }
            }
        }
        
        visit(start) // the first vertex is where everything begins
        
        while let edge = pq.pop() { // keep going as long as there are edges to process
            if visited[edge.v] { continue } // if we've been here, ignore
            result.append(edge) // otherwise this is the current smallest so add it to the result set
            visit(edge.v) // visit where this connects
        }
        
        return result
    }
    
    /// Pretty-print an edge list returned from an MST
    /// - parameter edges The edge array representing the MST
    func printWeightedPath(_ weightedPath: WeightedPath) {
        for edge in weightedPath {
            print("\(vertexAtIndex(edge.u)) \(edge.weight)> \(vertexAtIndex(edge.v))")
        }
        if let tw = totalWeight(weightedPath) {
            print("Total Weight: \(tw)")
        }
    }
}

print("== Minimum spanning tree ==")
if let mst = cityGraph2.mst() {
    cityGraph2.printWeightedPath(mst)
}
