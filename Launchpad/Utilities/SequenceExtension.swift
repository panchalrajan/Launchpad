import Foundation

extension Sequence {
   func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
      var seen = Set<T>()
      var result: [Element] = []
      result.reserveCapacity(underestimatedCount)
      for element in self {
         let key = element[keyPath: keyPath]
         if seen.insert(key).inserted {
            result.append(element)
         }
      }
      return result
   }
}
