import Foundation
import PrepUnits

extension Food {
    public class Nutrient {
        public var type: NutrientType
        public var amount: Double
        public var unit: NutrientUnit
        
        init(type: NutrientType, amount: Double, unit: NutrientUnit) {
            self.type = type
            self.amount = amount
            self.unit = unit
        }
    }
}


extension Food.Nutrient: Equatable {
    public static func ==(lhs: Food.Nutrient, rhs: Food.Nutrient) -> Bool {
        lhs.type == rhs.type
        && lhs.amount.rounded(toPlaces: 2) == rhs.amount.rounded(toPlaces: 2)
        && lhs.unit == rhs.unit
    }
}

extension Food.Nutrient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(amount)
        hasher.combine(unit)
    }
}
