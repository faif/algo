import Foundation

enum StackError: Error {
    case emptyStack
}

public class Stack<T>: CustomStringConvertible {
    private var container: [T] = [T]()
    public func push(item: T) { container.append(item) }
    public func pop() throws -> T {
        guard container.count > 0 else {
            throw StackError.emptyStack
        }
        return container.removeLast()
    }
    public var description: String { return container.description }
}

/// Move n disks from tower "from" to tower "to", using tower "temp" as the intermediate
///
/// - parameter from: the source tower
/// - parameter to: the destination tower
/// - parameter temp: the intermediate tower
/// - parameter n: the number of disks to move
func hanoi(from: Stack<Int>, to: Stack<Int>, temp: Stack<Int>, n: Int) {
    if n == 1 {  // move the single disk to the destination
        do {
            try to.push(item: from.pop())
        } catch StackError.emptyStack {
            print("No discs to move!")
        } catch {
            print("Unexpected error: \(error).")
        }
    } else {
        hanoi(from: from, to: temp, temp: to, n: n-1)  // move n-1 discs from A (source) to B using C (destination) as the temporary
        hanoi(from: from, to: to, temp: temp, n: 1)    // move the remaining single disk from A to C
        hanoi(from: temp, to: to, temp: from, n: n-1)  // move n-1 discs from B to C using A as the temporary
    }
}

let numDiscs = 3, towerA = Stack<Int>(), towerB = Stack<Int>(), towerC = Stack<Int>()
for i in 1...numDiscs {
    towerA.push(item: i)
}

print("initial state of tower A: \(towerA)")

hanoi(from: towerA, to: towerC, temp: towerB,  n: numDiscs)

print("State of tower A after the move: \(towerA)")
print("State of tower B after the move: \(towerB)")
print("State of tower C after the move: \(towerC)")
