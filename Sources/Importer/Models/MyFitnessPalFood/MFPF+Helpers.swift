import Foundation

public extension MyFitnessPalFood {
    var firstType: ServingType? {
        scrapedSizes.sorted { $0.index < $1.index }.first?.type
    }
    
    var baseSize: ScrapedSize? {
        guard let firstSize = scrapedSizes.first else {
            return nil
        }
        return firstSize
    }
    
    var secondSize: ScrapedSize? {
        guard scrapedSizes.count > 1 else {
            return nil
        }
        return scrapedSizes[1]
    }
    
    var firstWeightSize: ScrapedSize? {
        scrapedSizes.first(where: { $0.type == .weight })
    }
    
    var cleanedName: String {
        guard let name = name else {
            return ""
        }
        return name.cleaned
    }
    
    var cleanedBrand: String? {
        brand?.cleaned
    }
    
    /// returns the first match that contains a weight in the serving description so that we may determine the serving weight
    var servingsWithWeight: [ScrapedSize]? {
        let servings = scrapedSizes.filter {
            $0.type == .servingWithWeight
//            $0.unit.matchesRegex(RegExServingWithWeight)
        }
        return servings.isEmpty ? nil : servings
    }
    func servingsWithoutSameUnit(of serving: ScrapedSize) -> [ScrapedSize]? {
        let servings = scrapedSizes.filter {
            guard $0 != serving else { return false }
            return !$0.matchesUnit(of: serving)
        }
        return servings.count > 0 ? servings : nil
    }

    func servingsWithSameUnit(of serving: ScrapedSize) -> [ScrapedSize]? {
        let servings = scrapedSizes.filter {
            guard $0 != serving else { return false }
            return $0.matchesUnit(of: serving)
        }
        return servings.count > 0 ? servings : nil
    }
    var hasWeightServing: Bool {
//        servingSizes.contains { $0.isWeightBased }
        scrapedSizes.contains { $0.isWeightBased }
    }
    
    var defaultMeasuredServing: ScrapedSize? {
        scrapedSizes.first { $0.isWeightBased || $0.isVolumeBased }
    }
    
    var defaultServing: ScrapedSize? {
        scrapedSizes.first(where: { $0.index == 0 })
    }
}
