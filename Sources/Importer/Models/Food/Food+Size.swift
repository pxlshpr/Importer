import Foundation
import PrepUnits

extension Food {
    public class Size: Identifiable {
        public var id = UUID()
        
        public var name: String = ""
        public var nameVolumeUnit: VolumeUnit? = nil
        
        public var amount: Double = 0
        
        public var unit: UnitType = .weight
        public var volumeUnit: VolumeUnit? = nil
        public var weightUnit: WeightUnit? = nil
        public var size: Food.Size? = nil
        
        public var isDensity: Bool {
            guard nameVolumeUnit != nil, name.isEmpty else {
                return false
            }
            return true
        }
    }
}

extension Food.Size: Equatable {
    public static func ==(lhs: Food.Size, rhs: Food.Size) -> Bool {
        lhs.name == rhs.name
        && lhs.unit == rhs.unit
        && lhs.volumeUnit == rhs.volumeUnit
        && lhs.weightUnit == rhs.weightUnit
        && lhs.size == rhs.size
        && lhs.amount.rounded(toPlaces: 2) == rhs.amount.rounded(toPlaces: 2)
    }
}

extension Food.Size: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount)
        hasher.combine(unit)
        hasher.combine(volumeUnit)
        hasher.combine(weightUnit)
        hasher.combine(size)
    }
}
