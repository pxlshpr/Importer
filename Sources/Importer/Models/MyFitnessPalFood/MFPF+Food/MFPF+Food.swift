import Foundation
import PrepUnits

extension MFPFood {
    public var food: Food? {
        guard let firstType = firstType else {
            print("No firstType from: \(sizes.count) sizes")
            return nil
        }
        
        switch firstType {
        case .weight:
            return foodStartingWithWeight
        case .volume:
            return foodStartingWithVolume
//        case .serving:
//            return foodStartingWithServing
//        case .servingWithWeight:
//            return foodStartingWithServingWithWeight
//        case .servingWithVolume:
//            return foodStartingWithServingWithVolume
//        case .weightWithServing:
//            return foodStartingWithWeightWithServing
        case .serving, .servingWithWeight, .servingWithVolume, .weightWithServing:
            return servingBasedFood
        case .volumeWithServing:
            return foodStartingWithVolumeWithServing
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
        food.amountUnit = .serving
        
        food.energy = energy ?? 0
        food.carbohydrate = carb ?? 0
        food.fat = fat ?? 0
        food.protein = protein ?? 0
        
        food.nutrients = nutrients.foodNutrients
        
        food.sourceUrl = "https://www.myfitnesspal.com\(urlSlug)"
        return food
    }
    
    //MARK: - Helpers
    
    //TODO: Remove
//    static func createSizes(from sizes: [Size], unit: UnitType, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
//        sizes
//            .filter { !$0.name.isEmpty }
//            .map { Food.Size(mfpSize: $0, unit: unit, amount: amount) }
//            .removingDuplicates()
//            .filter { $0 != baseFoodSize }
//    }
}

extension Array where Element == MFPFood.Nutrient {
    var foodNutrients: [Food.Nutrient] {
        map {
            Food.Nutrient(type: $0.type, amount: $0.amount, unit: $0.unit)
        }
    }
}
