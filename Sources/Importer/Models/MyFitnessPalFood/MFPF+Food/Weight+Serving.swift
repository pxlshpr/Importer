import Foundation

extension MFPFood {
    var foodStartingWithWeightWithServing: Food? {
        
        /// protect against division by 0 with baseSize.value check
        guard let firstSize = sizes.first, firstSize.value > 0 else {
            return nil
        }
        
        let parsed = firstSize.name.parsedWeightWithServing
        guard let serving = parsed.serving,
              let servingAmount = serving.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }
        
        let food = baseFood
        food.servingAmount = servingAmount
        food.servingUnit = .size
        
        let baseWeight = firstSize.processedSize.g(for: firstSize.value, unit: weightUnit)
        
        let size = Food.Size()
        size.name = serving.name.capitalized
        size.amountUnitType = .weight
        size.amount = baseWeight / servingAmount
        
        food.setAmount(basedOn: baseWeight)
//        food.amount = baseWeight < 100 ? 100 / baseWeight : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .weight, amount: size.amount * servingAmount, baseFoodSize: size)
        )

        food.sizes.append(contentsOf: sizes.filter { mfpSize in
            mfpSize.type == .servingWithWeight
        }.compactMap { mfpSize -> Food.Size? in
            let s = Food.Size()
            let parsed = mfpSize.name.parsedServingWithWeight
            guard let serving = parsed.serving else {
                print("Couldn't parse servingWithWeight: \(mfpSize)")
                return nil
            }
            s.name = serving.name
            s.amountUnitType = .size
            s.amount = firstSize.multiplier * mfpSize.multiplier * baseWeight / size.amount
            s.amountSizeUnit = size
            return s
        })

        food.sizes.append(contentsOf: sizes.filter { mfpSize in
            mfpSize.type == .servingWithServing
        }.map { mfpSize -> Food.Size in
            let s = Food.Size()
            let parsed = mfpSize.name.parsedServingWithServing
            if let servingName = parsed.serving?.name {
                s.name = servingName
            } else {
                s.name = mfpSize.cleanedName
            }
            s.amountUnitType = .size
            s.amount = firstSize.multiplier * mfpSize.multiplier * baseWeight
            s.amountSizeUnit = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
    
}
