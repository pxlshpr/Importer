import Foundation

extension MyFitnessPalFood {
    var foodStartingWithWeightWithVolume: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        
        let parsed = baseSize.name.parsedWeightWithVolume
        guard let weightUnit = parsed.weight?.unit,
              let volumeAmount = parsed.volume?.amount,
              let volumeUnit = parsed.volume?.unit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .weight
        food.servingAmount = baseSize.processedSize.g(for: baseSize.value, unit: weightUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        //TODO: Density
        let densityWeight = food.servingAmount
        let densityVolume = baseSize.processedSize.ml(for: volumeAmount, unit: volumeUnit)
        
        food.density = Density(volume: densityVolume, weight: densityWeight)
        
        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = volumeUnit.description.capitalized
            size.amount = 1.0/volumeAmount
            size.unit = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithWeight
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                let parsed = scrapedSize.name.parsedServingWithWeight
                guard let serving = parsed.serving else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = serving.name
                s.unit = .size
                s.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
                s.size = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .servingWithWeight
            }
            food.sizes.append(
                contentsOf:
                    createSizes(from: sizesToAdd, unit: .weight, amount: food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
