import Foundation

extension MyFitnessPalFood {
    var foodStartingWithWeight: Food? {
        guard let baseSize = baseSize, let g = baseSize.processedSize.g else {
            return nil
        }
        
        let food = baseFood
        //TODO: Make food volume based for those starting with volume too
        food.unit = .weight
        food.servingUnit = .weight
        
        //TODO: We weren't correctly considering the multiplier—so check all other cases for this. Check the weight being set correctly, then used correctly in sizes and when scaling nutrients
        let weight = g * baseSize.value / baseSize.multiplier
        
        //TODO: Try setting amount to weight and not setting a serving value
        food.amount = weight
        food.servingAmount = 0
        
//        food.setAmount(basedOn: weight)
//        food.servingAmount = weight
        
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type != .weight && $0.type != .volume
        }
        food.sizes.append(
            contentsOf: createSizes(
//                from: sizesToAdd, unit: .g, amount: (g * baseSize.value)
                from: sizesToAdd, unit: .weight, amount: weight
            )
        )
        
//        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
//        food.scaleNutrientsBy(scale: food.amount / weight * baseSize.multiplier)
        food.scaleNutrientsBy(scale: food.amount / weight)
        return food
    }
}
