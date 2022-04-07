import PrepUnits

extension MFPFood {
    public struct Nutrient {
        public let type: NutrientType
        public let amount: Double
        public let unit: NutrientUnit
    }
}

extension MFPFood.Nutrient: Equatable {
    public static func ==(lhs: MFPFood.Nutrient, rhs: MFPFood.Nutrient) -> Bool {
        lhs.type == rhs.type
        && lhs.amount == rhs.amount
        && lhs.unit == rhs.unit
    }
}

extension MFPFood.Nutrient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(amount)
        hasher.combine(unit)
    }
}
