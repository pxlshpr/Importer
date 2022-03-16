import Foundation

extension MFPFood {
    var foodStartingWithServingWithWeight: Food? {
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
        food.servingAmount = firstSize.value
        food.servingUnit = .size
        
        let size = Food.Size()
        size.name = serving.name.cleaned.capitalized
        size.amountUnitType = .weight
        size.amount = firstSize.processedSize.g(for: servingAmount, unit: weightUnit) / firstSize.value
        
        food.amount = 1
        
        food.servingSize = size
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
            remainingSize.amountUnitType = .size
            remainingSize.amount = firstSize.multiplier * mfpSize.multiplier * firstSize.value
            remainingSize.amountSizeUnit = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
