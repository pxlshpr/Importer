import Foundation
import PrepUnits

//4D3536AB
public struct Density {
    public let volumeAmount: Double
    public let volumeUnit: VolumeUnit
    public let weightAmount: Double
    public let weightUnit: WeightUnit
}

//extension Density: Equatable {
//    public static func ==(lhs: Density, rhs: Density) -> Bool {
//        lhs.volume / lhs.weight == rhs.volume / rhs.weight
//    }
//}
