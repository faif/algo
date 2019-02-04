import Foundation

/// Calculate and return the nth term of the Fibonacci sequence
///
/// - parameter n: the term to calculate
/// - returns: the calculated result
func fibonacci(n: UInt) -> UInt {
    if (n == 0) {
        return n
    }
    var last: UInt = 0, next: UInt = 1
    for _ in 1..<n {
        (last, next) = (next, last + next)
    }
    return next
}

let fib_term: UInt = 40, result: UInt = fibonacci(n: fib_term)
print("fibonacci(\(fib_term)) = \(result)")
