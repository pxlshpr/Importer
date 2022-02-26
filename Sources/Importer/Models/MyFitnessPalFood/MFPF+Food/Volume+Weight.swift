import Foundation

extension MyFitnessPalFood {
    var foodStartingWithVolumeWithWeight: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0,
              let parsed = ServingType.parseVolumeWithWeight(baseSize.name),
              let volumeUnit = parsed.volume?.unit,
              let volumeString = parsed.volume?.string,
              let weightAmount = parsed.weight?.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .mL
        food.servingAmount = baseSize.processedSize.ml(for: baseSize.value, unit: volumeUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        food.densityWeight = baseSize.processedSize.g(for: weightAmount, unit: weightUnit)
        food.densityVolume = food.servingAmount
        
        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeString.capitalized
            size.amount = 1.0/baseSize.value
            size.unit = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithVolume
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                guard
                    let parsed = ServingType.parseServingWithVolume(scrapedSize.name),
                    let servingName = parsed.serving?.name
                else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = servingName
                s.unit = .size
                s.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
                s.size = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .servingWithVolume
            }
            food.sizes.append(
                contentsOf: createSizes(from: sizesToAdd, unit: .mL, amount: baseSize.value * food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
