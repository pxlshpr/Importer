import Foundation

extension MFPFood {
    var foodStartingWithWeightWithVolume: Food? {
        /// protect against division by 0 with firstSize.value check
        guard let firstSize = sizes.first, firstSize.value > 0 else {
            return nil
        }
        
        let parsed = firstSize.name.parsedWeightWithVolume
        guard let weightUnit = parsed.weight?.unit,
              let volumeAmount = parsed.volume?.amount,
              let volumeUnit = parsed.volume?.unit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .weight
        food.servingAmount = firstSize.processedSize.g(for: firstSize.value, unit: weightUnit)
        food.amount = 1
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        //TODO: Density
        let densityWeight = food.servingAmount
        let densityVolume = firstSize.processedSize.ml(for: volumeAmount, unit: volumeUnit)
        
        food.density = Density(volume: densityVolume, weight: densityWeight)
        
        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeUnit.description.capitalized
            size.amount = 1.0/volumeAmount
            size.amountUnitType = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: sizes.filter { mfpSize in
                mfpSize.type == .servingWithWeight
            }.compactMap { mfpSize -> Food.Size? in
                let s = Food.Size()
                let parsed = mfpSize.name.parsedServingWithWeight
                guard let serving = parsed.serving else {
                    print("Couldn't parse servingWithVolume: \(mfpSize)")
                    return nil
                }
                s.name = serving.name
                s.amountUnitType = .size
                s.amount = firstSize.multiplier * mfpSize.multiplier * firstSize.value
                s.amountSizeUnit = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = sizes.dropFirst().filter {
                $0.type == .servingWithWeight
            }
            food.sizes.append(
                contentsOf:
                    MFPFood.createSizes(from: sizesToAdd, unit: .weight, amount: food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
