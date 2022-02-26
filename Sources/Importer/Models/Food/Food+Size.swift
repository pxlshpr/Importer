import Foundation
import PrepUnits

extension Food {
    public class Size: Identifiable {
        public var id = UUID()
        public var name: String = ""
        public var amount: Double = 0
        
        public var unit: SizeUnit = .g
        public var volumeUnit: VolumeUnit? = nil
        public var size: Food.Size? = nil
    }
}

extension Food.Size: Equatable {
    public static func ==(lhs: Food.Size, rhs: Food.Size) -> Bool {
        lhs.name == rhs.name
        && lhs.unit == rhs.unit
        && lhs.amount.rounded(toPlaces: 2) == rhs.amount.rounded(toPlaces: 2)
    }
}

extension Food.Size: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount)
        hasher.combine(unit)
        hasher.combine(size)        
    }
}
