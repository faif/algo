import Foundation

/// Calculate Pi using the Leibniz formula
///
/// - parameter terms: the number of terms in the series (higher gives better accuracy)
/// - returns: the Pi approximation
func calculatePi(terms: UInt) -> Double {
    let numerator: Double = 4
    var denominator: Double = 1
    var operation: Double = 1
    var pi: Double = 0
    for _ in 0..<terms {
        pi += operation * (numerator / denominator)
        denominator += 2
        operation *= -1
    }
    return abs(pi)
}

let terms: UInt = 1000, result = calculatePi(terms: terms)
print("approximation of Pi using \(terms) terms = \(result)")
