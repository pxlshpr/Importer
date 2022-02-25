import Foundation

extension MyFitnessPalFood {
    var foodStartingWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        let food = baseFood
        food.servingUnit = .size
        food.servingAmount = baseSize.value
        
        let size = Food.Size()
        size.name = baseSize.cleanedName.capitalized
        
        let total: Double
        /// check if we have any weight size
        if let weightSize = firstWeightSize, let weight = weightSize.processedSize.g {
            /// translates an entry of `1 g - x0.01` to `100g`
            total = weight / weightSize.multiplier
            let baseWeight = total * baseSize.multiplier
            
            food.setAmount(basedOn: baseWeight)
//            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
            size.unit = .g
            size.amount = baseWeight / baseSize.value
            
            food.sizes.append(size)
            food.servingSize = size
            
        } else {
            food.amount = 1
            size.unit = .serving
            size.amount = 1.0/baseSize.value
            
            total = baseSize.multiplier
            
            food.sizes.append(size)
            food.servingSize = size
        }
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(contentsOf:
                            createSizes(from: sizesToAdd, unit: size.unit, amount: total, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let remainingSize = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                remainingSize.name = parsed.serving.capitalized
            } else {
                remainingSize.name = scrapedSize.cleanedName.capitalized
            }
            remainingSize.unit = .size
            remainingSize.amount = total * scrapedSize.multiplier * baseSize.value
            remainingSize.size = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}