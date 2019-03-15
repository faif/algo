import Foundation

/// Search for item in array using binary search
///
/// - parameter array: the input array
/// - parameter item: the item to search for
/// - returns: true if item is found, false otherwise
func binaryContains<T: Comparable>(array: [T], item: T) -> Bool {
    var low = 0, high = array.count - 1
    while low <= high {
        let mid = (low + high) / 2
        if array[mid] < item {
            low = mid + 1
        } else if array[mid] > item {
            high = mid - 1
        } else {
            return true
        }
    }
    return false
}

let myItems = ["a", "d", "e", "f", "g", "l", "r"], toFind = "f"
print("myItems: \(myItems)")
let exists = binaryContains(array: myItems, item: toFind)
print("\(toFind) in myItems: \(exists)")
