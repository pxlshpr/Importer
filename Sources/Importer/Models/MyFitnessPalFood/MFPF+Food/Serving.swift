import Foundation

extension MFPFood {
    var foodStartingWithServing: Food? {
        /// protect against division by 0 with firstSize.value check
        guard let firstSize = sizes.first, firstSize.value > 0 else {
            return nil
        }
        let food = baseFood
        food.servingUnit = .size
        food.servingAmount = firstSize.value
        
        let size = Food.Size()
        size.name = firstSize.cleanedName.capitalized
        
        let total: Double
        /// check if we have any weight size
        if let weightSize = firstWeightSize, let weight = weightSize.processedSize.g {
            /// translates an entry of `1 g - x0.01` to `100g`
            total = weight / weightSize.multiplier
            let baseWeight = total * firstSize.multiplier
            
            food.setAmount(basedOn: baseWeight)
//            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
            size.amountUnitType = .weight
            size.amount = baseWeight / firstSize.value
            
            food.sizes.append(size)
            food.servingSize = size
            
        } else {
            food.amount = 1
            size.amountUnitType = .serving
            size.amount = 1.0/firstSize.value
            
            total = firstSize.multiplier
            
            food.sizes.append(size)
            food.servingSize = size
        }
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(contentsOf:
                            MFPFood.createSizes(from: sizesToAdd, unit: size.amountUnitType, amount: total, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: sizes.filter { mfpSize in
            mfpSize.type == .servingWithServing
        }.map { mfpSize -> Food.Size in
            let remainingSize = Food.Size()
            if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
                remainingSize.name = servingName.capitalized
            } else {
                remainingSize.name = mfpSize.cleanedName.capitalized
            }
            remainingSize.amountUnitType = .size
            remainingSize.amount = total * mfpSize.multiplier * firstSize.value
            remainingSize.amountSizeUnit = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
