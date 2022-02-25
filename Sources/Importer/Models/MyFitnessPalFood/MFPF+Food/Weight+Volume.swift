import Foundation

extension MyFitnessPalFood {
    var foodStartingWithWeightWithVolume: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0, let parsed = ServingType.parseWeightWithVolume(baseSize.name), let weightUnit = parsed.weightUnit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .g
        food.servingAmount = baseSize.processedSize.g(for: baseSize.value, unit: weightUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        food.densityWeight = food.servingAmount
        food.densityVolume = baseSize.processedSize.ml(for: parsed.volume, unit: parsed.volumeUnit)
        
        if parsed.volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = parsed.volumeUnit.description.capitalized
            size.amount = 1.0/parsed.volume
            size.unit = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithWeight
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                guard let parsed = ServingType.parseServingWithWeight(scrapedSize.name) else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = parsed.name
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
                    createSizes(from: sizesToAdd, unit: .g, amount: food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
