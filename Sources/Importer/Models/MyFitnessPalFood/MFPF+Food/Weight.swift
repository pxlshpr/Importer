import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithWeight: Food? {
        guard let firstSize = sizes.first, let weight = firstSize.weightConvertedForUnits else {
            return nil
        }
        
        let food = baseFood
        
        food.amount = 1
        food.amountUnit = .serving
        
        food.servingUnit = .weight
        food.servingValue = weight.amount
        food.servingWeightUnit = weight.unit
        
        /// check for a volume based unit indicating a density
        //TODO: Density needs to be added if volume units are present, e.g "Drink, Yakult", "Gimbir"
        if let density = sizes.density {
            food.density = density
        }
        
        /// add all remaining sizes except for raw volumes and weights
        let types = Array(Set(ServingType.allCases).subtracting([ServingType.volume, ServingType.weight]))
        food.importMFPSizes(from: sizes, ofTypes: types)
        
        return food
     }
}

//TODO: Ratio's need to be divided by, not multiplied, e.g. "Ghimbir..."

//TODO: First look for a weight that has a ratio of 1 and use that, e.g. "Ghimbir..."
