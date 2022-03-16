import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithWeight: Food? {
        guard let firstSize = sizes.first else {
            return nil
        }
        
        let food = baseFood
        food.amount = firstSize.trueValue
        food.amountUnit = .weight
        food.amountWeightUnit = firstSize.weightUnit
        
//        let weight = g * firstSize.value / firstSize.multiplier
        
        //TODO: Try setting amount to weight and not setting a serving value
//        food.amount = weight
//        food.servingValue = 0
        
//        food.setAmount(basedOn: weight)
//        food.servingAmount = weight
        
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type != .weight && $0.type != .volume
        }
        food.sizes.append(
            contentsOf: MFPFood.createSizes(
                from: sizesToAdd, unit: .weight, amount: firstSize.trueValue
            )
        )
        
//        food.scaleNutrientsBy(scale: food.amount / weight)
        return food
    }
}
