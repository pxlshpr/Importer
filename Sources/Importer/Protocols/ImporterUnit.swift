import Foundation

public protocol ImporterUnit {
    var unitId: String { get }
    var nameSingular: String { get }
    var namePlural: String { get }
}

public extension ImporterUnit {
    func unitDescription(forValue value: Double = 1, withServingSize: Bool = true, withTotalSize: Bool = false) -> String {
        return ""
//        if let size = self as? Food.Size {
//            return size.unitDescription(forValue: value, withServingSize: withServingSize, withTotalSize: withTotalSize)
//        } else if let rawUnit = self as? RawUnit {
//            return rawUnit.unitDescription(forValue: value)
//        } else {
//            return "Unsupported Unit"
//        }
    }
}

