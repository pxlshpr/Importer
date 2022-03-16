import Foundation


//TODO: Remove this
extension MFPFood {
    var foodStartingWithVolumeWithDescription: Food? {
        //TODO: Rewrite this
        
        /// protect against division by 0 with firstSize.value check
        guard let firstSize = sizes.first, firstSize.value > 0 else {
            return nil
        }
        let parsed = firstSize.name.parsedVolumeWithWeight
        guard let volumeUnit = parsed.volume?.unit,
              let volumeString = parsed.volume?.string,
              let weightAmount = parsed.weight?.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .volume
        food.servingAmount = firstSize.processedSize.ml(for: firstSize.value, unit: volumeUnit)
        food.amount = 1
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        let densityWeight = firstSize.processedSize.g(for: weightAmount, unit: weightUnit)
        let densityVolume = food.servingAmount
        
        food.density = Density(volume: densityVolume, weight: densityWeight)

        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeString.capitalized
            size.amount = 1.0/firstSize.value
            size.amountUnitType = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: sizes.filter { mfpSize in
                mfpSize.type == .servingWithVolume
            }.compactMap { mfpSize -> Food.Size? in
                let s = Food.Size()
                let parsed = mfpSize.name.parsedServingWithVolume
                guard let servingName = parsed.serving?.name else {
                    print("Couldn't parse servingWithVolume: \(mfpSize)")
                    return nil
                }
                s.name = servingName
                s.amountUnitType = .size
                s.amount = firstSize.multiplier * mfpSize.multiplier * firstSize.value
                s.amountSizeUnit = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = sizes.dropFirst().filter {
                $0.type == .servingWithVolume
            }
            food.sizes.append(
                contentsOf: MFPFood.createSizes(from: sizesToAdd, unit: .volume, amount: firstSize.value * food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
