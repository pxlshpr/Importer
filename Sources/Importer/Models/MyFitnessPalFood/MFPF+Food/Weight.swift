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
                
        food.density = sizes.density
        
        let types = ServingType.all(excluding: [ServingType.volume, ServingType.weight])
        food.importMFPSizes(from: sizes, ofTypes: types)
        
        return food
     }
}
