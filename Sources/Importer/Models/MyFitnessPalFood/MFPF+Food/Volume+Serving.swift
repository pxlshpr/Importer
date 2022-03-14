import Foundation

extension MyFitnessPalFood {
    var foodStartingWithVolumeWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        
        let parsed = baseSize.name.parsedVolumeWithServing
        guard let servingName = parsed.serving?.name,
              let volumeUnit = parsed.volume?.unit
        else {
            return nil
        }
        
        let food = baseFood
        food.servingAmount = baseSize.value
        food.servingUnit = .size
        
        let baseVolume = baseSize.processedSize.ml(for: baseSize.value, unit: volumeUnit)
        
        let size = Food.Size()
        size.name = servingName.capitalized
        size.unit = .volume
        size.amount = baseVolume / baseSize.value
        
        food.setAmount(basedOn: baseVolume)
//        food.amount = baseVolume < 100 ? 100 / baseVolume : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .volume, amount: size.amount * baseSize.value, baseFoodSize: size)
        )

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
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume / size.amount
            s.size = size
            return s
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            if let servingName = scrapedSize.name.parsedServingWithServing.serving?.name {
                s.name = servingName
            } else {
                s.name = scrapedSize.cleanedName
            }
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
            s.size = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
