import Foundation

extension MFPFood {
    var foodStartingWithVolumeWithDescription: Food? {
        //TODO: Rewrite this
        
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        let parsed = baseSize.name.parsedVolumeWithWeight
        guard let volumeUnit = parsed.volume?.unit,
              let volumeString = parsed.volume?.string,
              let weightAmount = parsed.weight?.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .volume
        food.servingAmount = baseSize.processedSize.ml(for: baseSize.value, unit: volumeUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        let densityWeight = baseSize.processedSize.g(for: weightAmount, unit: weightUnit)
        let densityVolume = food.servingAmount
        
        food.density = Density(volume: densityVolume, weight: densityWeight)

        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeString.capitalized
            size.amount = 1.0/baseSize.value
            size.amountUnitType = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithVolume
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                let parsed = scrapedSize.name.parsedServingWithVolume
                guard let servingName = parsed.serving?.name else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = servingName
                s.amountUnitType = .size
                s.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
                s.amountSizeUnit = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .servingWithVolume
            }
            food.sizes.append(
                contentsOf: createSizes(from: sizesToAdd, unit: .volume, amount: baseSize.value * food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
