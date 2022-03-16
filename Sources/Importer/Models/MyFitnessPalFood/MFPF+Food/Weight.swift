import Foundation

extension MFPFood {
    var foodStartingWithWeight: Food? {
        guard let firstSize = sizes.first, let g = firstSize.processedSize.g else {
            return nil
        }
        
        let food = baseFood
        //TODO: Make food volume based for those starting with volume too
        food.amountUnit = .weight
        food.servingUnit = .weight
        
        //TODO: We weren't correctly considering the multiplier—so check all other cases for this. Check the weight being set correctly, then used correctly in sizes and when scaling nutrients
        let weight = g * firstSize.value / firstSize.multiplier
        
        //TODO: Try setting amount to weight and not setting a serving value
        food.amount = weight
        food.servingAmount = 0
        
//        food.setAmount(basedOn: weight)
//        food.servingAmount = weight
        
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type != .weight && $0.type != .volume
        }
        food.sizes.append(
            contentsOf: MFPFood.createSizes(
//                from: sizesToAdd, unit: .g, amount: (g * firstSize.value)
                from: sizesToAdd, unit: .weight, amount: weight
            )
        )
        
//        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
//        food.scaleNutrientsBy(scale: food.amount / weight * firstSize.multiplier)
        food.scaleNutrientsBy(scale: food.amount / weight)
        return food
    }
}
