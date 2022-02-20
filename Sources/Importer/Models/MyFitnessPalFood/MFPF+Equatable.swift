import Foundation

extension MyFitnessPalFood: Equatable {
    public static func ==(lhs: MyFitnessPalFood, rhs: MyFitnessPalFood) -> Bool {
        lhs.id == rhs.id
    }
}

extension MyFitnessPalFood.ScrapedSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(multiplier)
        hasher.combine(index)
    }
}
extension MyFitnessPalFood: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(brand)
        hasher.combine(energy)
        hasher.combine(carb)
        hasher.combine(fat)
        hasher.combine(protein)
        hasher.combine(scrapedSizes)
        hasher.combine(processedSizes)
    }
}
