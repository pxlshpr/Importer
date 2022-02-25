import Foundation

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
        var sizes: [Food.Size] = []
        for scrapedSize in scrapedSizes {
            
            /// skip sizes with blank names
            guard !scrapedSize.name.isEmpty else { continue }
            
            let size = Food.Size()
            if scrapedSize.type == .servingWithWeight, let parsed = ServingType.parseServingWithWeight(scrapedSize.name) {
                size.name = parsed.name.capitalized
            } else if scrapedSize.type == .servingWithVolume, let parsed = ServingType.parseServingWithVolume(scrapedSize.name) {
                size.name = parsed.name.capitalized
            } else if scrapedSize.type == .servingWithServing, let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                size.name = parsed.serving.capitalized
            } else {
                size.name = scrapedSize.cleanedName.capitalized
            }
            size.unit = unit
            size.amount = amount * scrapedSize.multiplier
            
            if !sizes.contains(size) && size != baseFoodSize {
                sizes.append(size)
            }
        }
        return sizes
    }
}
