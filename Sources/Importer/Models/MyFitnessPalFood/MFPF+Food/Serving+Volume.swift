import Foundation

extension MyFitnessPalFood {
    var foodStartingWithServingWithVolume: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        let parsed = baseSize.name.parsedServingWithVolume
        guard let serving = parsed.serving,
              let servingAmount = serving.amount,
              let volumeUnit = parsed.volume?.unit
        else {
            return nil
        }
        
        let food = baseFood
        food.servingAmount = baseSize.value
        food.servingUnit = .size
        
        let size = Food.Size()
        size.name = serving.name.capitalized
        size.unit = .volume
        size.amount = baseSize.processedSize.ml(for: servingAmount, unit: volumeUnit) / baseSize.value
        
        food.setAmount(basedOn: size.amount)
//        food.amount = size.amount < 100 ? 100 / size.amount : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(contentsOf:
                            createSizes(from: sizesToAdd, unit: .volume, amount: size.amount, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let remainingSize = Food.Size()
            let parsed = scrapedSize.name.parsedServingWithServing
            if let servingName = parsed.serving?.name {
                remainingSize.name = servingName.capitalized
            } else {
                remainingSize.name = scrapedSize.cleanedName.capitalized
            }
            remainingSize.unit = .size
            remainingSize.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
            remainingSize.size = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
