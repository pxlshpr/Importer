import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithWeight: Food? {
        guard let firstSize = sizes.first else {
            return nil
        }
        
        let food = baseFood
        
        food.amount = 1
        food.amountUnit = .serving
        
        food.servingValue = firstSize.trueValue
        food.servingUnit = .weight
        food.servingWeightUnit = firstSize.weightUnit
                
        let types = Array(Set(ServingType.allCases).subtracting([ServingType.volume, ServingType.weight]))
        food.importMFPSizes(from: sizes, ofTypes: types)
        
//        //TODO: Change this
//        let sizesToAdd = sizes.dropFirst().filter {
//            $0.type != .weight && $0.type != .volume
//        }
//        food.sizes.append(
//            contentsOf: MFPFood.createSizes(
//                from: sizesToAdd, unit: .weight, amount: firstSize.trueValue
//            )
//        )
        
        return food
    }
}

//TODO: Density needs to be added if volume units are present, e.g "Drink, Yakult", "Gimbir"

//TODO: Ratio's need to be divided by, not multiplied, e.g. "Ghimbir..."

//TODO: First look for a weight that has a ratio of 1 and use that, e.g. "Ghimbir..."
