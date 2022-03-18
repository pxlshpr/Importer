import Foundation
import PrepUnits

extension Food {
    public class Size: Identifiable {
//        public var id = UUID()

        public var quantity: Double = 1
        
        public var name: String = ""
        public var nameVolumeUnit: VolumeUnit? = nil
        
        public var amount: Double = 0
        
        public var amountUnit: UnitType = .weight
        public var amountVolumeUnit: VolumeUnit? = nil
        public var amountWeightUnit: WeightUnit? = nil
        public var amountSizeUnit: Food.Size? = nil
        
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
        && lhs.nameVolumeUnit == rhs.nameVolumeUnit
        && lhs.amountUnit == rhs.amountUnit
        && lhs.amountVolumeUnit == rhs.amountVolumeUnit
        && lhs.amountWeightUnit == rhs.amountWeightUnit
        && lhs.amountSizeUnit == rhs.amountSizeUnit
        && lhs.amount.rounded(toPlaces: 2) == rhs.amount.rounded(toPlaces: 2)
        && lhs.quantity.rounded(toPlaces: 2) == rhs.quantity.rounded(toPlaces: 2)
    }
}

extension Food.Size: Hashable {
    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
        hasher.combine(quantity)
        hasher.combine(name)
        hasher.combine(nameVolumeUnit)
        hasher.combine(amount)
        hasher.combine(amountUnit)
        hasher.combine(amountVolumeUnit)
        hasher.combine(amountWeightUnit)
        hasher.combine(amountSizeUnit)
    }    
}
