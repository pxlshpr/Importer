import Foundation

extension MFPFood {
    
    var foodStartingWithServingWithWeight: Food? {
        guard let firstSize = sizes.first,
              let firstFoodSize = Food.Size(servingWithWeight: firstSize, firstMFPSize: firstSize)
        else {
            return nil
        }
        
        let food = baseFood

        food.amount = 1
        food.amountUnit = .serving
        
        food.servingUnit = .size
        food.servingValue = firstSize.value
        food.servingSizeUnit = firstFoodSize

        food.density = sizes.density
        
        food.sizes.append(firstFoodSize)
                
        let types = ServingType.all(excluding: [ServingType.volume, ServingType.weight])
        food.importMFPSizes(from: sizes, ofTypes: types)
        
        return food
    }
    
    var foodStartingWithServingWithWeight_legacy: Food? {
        /// protect against division by 0 with firstSize.value check
        guard let firstSize = sizes.first, firstSize.value > 0 else {
            return nil
        }
        let parsed = firstSize.name.parsedServingWithWeight
        guard let serving = parsed.serving,
              let servingAmount = serving.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }
        
        let food = baseFood
        food.servingValue = firstSize.value
        food.servingUnit = .size
        
        let size = Food.Size()
        size.name = serving.name.cleaned.capitalized
        size.amountUnit = .weight
        size.amount = firstSize.processedSize.g(for: servingAmount, unit: weightUnit) / firstSize.value
        
        food.amount = 1
        
        food.servingSizeUnit = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups) || $0.type == .servingWithVolume || $0.type == .servingWithWeight
        }
        food.sizes.append(contentsOf:
                            MFPFood.createSizes(from: sizesToAdd, unit: .weight, amount: size.amount, baseFoodSize: size)
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
            remainingSize.amountUnit = .size
            remainingSize.amount = firstSize.multiplier * mfpSize.multiplier * firstSize.value
            remainingSize.amountSizeUnit = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
