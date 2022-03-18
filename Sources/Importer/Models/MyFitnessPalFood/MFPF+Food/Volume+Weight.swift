import Foundation

extension MFPFood {
    
    var foodStartingWithVolumeWithWeight: Food? {
        guard let firstSize = sizes.first, let firstFoodSize = firstFoodSize else {
            return nil
        }
        
        /// if we have a `servingName` for the `parsedVolumeWithWeight`
        ///     if we also don't have any other `volumeWithWeight`'s or `volumeWithServing`s (indicating that this is the sole density for the food)—other meaning with a different `servingName` — since it could simply be expressed with different units in a different mfp.size
        ///         - set the `servingName` as the food's description
        ///         - set the serving unit for the food to be volume based
        ///         - set the trueValue of the size as its amount
        ///         - set the density based off the weight of the `parsedVolumeWithWeight`
        ///     else
        ///         - set the serving unit for the food to be size based
        ///         - create a size with the `volumeWithWeight`
        ///             - just like we would have with a `volumeWithServing`
        ///         - add the size to the foods sizes
        ///         - (don't set the density as we have other ones)
        /// else (we don't have a `servingName`)
        ///     - set the serving unit for the food to be volume based
        ///     - set the trueValue of the size to be its amount
        ///     - set the density based off the weight of the `parsedVolumeWithWeight`
        return nil
    }
    
    
    var foodStartingWithVolumeWithWeight_legacy: Food? {
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
        food.servingValue = firstSize.processedSize.ml(for: firstSize.value, unit: volumeUnit)
        
        food.amount = 1
        
        /// now get the weight unit
        let densityWeight = firstSize.processedSize.g(for: weightAmount, unit: weightUnit)
        let densityVolume = food.servingValue
        
        //TODO: Density
//        food.density = Density(volume: densityVolume, weight: densityWeight)

        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeString.capitalized
            size.amount = 1.0/firstSize.value
            size.amountUnit = .serving
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
                s.amountUnit = .size
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
                contentsOf: MFPFood.createSizes(from: sizesToAdd, unit: .volume, amount: firstSize.value * food.servingValue)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        return food
    }
}
