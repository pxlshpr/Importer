import Foundation
import PrepUnits

extension MyFitnessPalFood {
    public var food: Food? {
        guard let firstType = firstType else {
            print("No firstType from: \(scrapedSizes.count) sizes")
            return nil
        }
        switch firstType {
        case .weight:
            return foodStartingWithWeight
        case .volume:
            return foodStartingWithVolume
        case .serving:
            return foodStartingWithServing
        case .servingWithWeight:
            return foodStartingWithServingWithWeight
        case .servingWithVolume:
            return foodStartingWithServingWithVolume
        case .weightWithServing:
            return foodStartingWithWeightWithServing
        case .volumeWithWeight:
            return foodStartingWithVolumeWithWeight
        case .weightWithVolume:
            return foodStartingWithWeightWithVolume
        default:
            return Food()
        }
    }
    
    var baseFood: Food {
        let food = Food()
        food.name = cleanedName
        food.brand = cleanedBrand
        food.unit = .serving
        food.energy = energy ?? 0
        food.carbohydrate = carb ?? 0
        food.fat = fat ?? 0
        food.protein = protein ?? 0
        return food
    }
    
    //MARK: - Helpers
    
    func createSizes(from scrapedSizes: [ScrapedSize], unit: SizeUnit, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
        scrapedSizes
            .filter { !$0.name.isEmpty }
            .map { Food.Size($0) }
            .removingDuplicates()
            .filter { $0 != baseFoodSize }
    }
}

extension Food.Size {
    convenience init(_ scrapedSize: MyFitnessPalFood.ScrapedSize) {
        self.init()
        
        let size = Food.Size()

        size.name = scrapedSize.cleanedName.capitalized
        
        if scrapedSize.type == .servingWithWeight, let parsed = ServingType.parseServingWithWeight(scrapedSize.name)
        {
            size.name = parsed.name.capitalized
        }
        else if scrapedSize.type == .servingWithVolume, let parsed = ServingType.parseServingWithVolume(scrapedSize.name)
        {
            size.name = parsed.name.capitalized
        }
        else if scrapedSize.type == .servingWithServing, let parsed = ServingType.parseServingWithServing(scrapedSize.name)
        {
            size.name = parsed.serving.capitalized
        }
        
        size.unit = unit
        size.amount = amount * scrapedSize.multiplier
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
