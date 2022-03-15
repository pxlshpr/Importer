import Foundation

extension MFPFood {
    
    var foodStartingWithVolumeWithServing: Food? {
        
        /// protect against division by 0 with baseSize.value check
        guard let baseMFPSize = baseSize,
              baseMFPSize.value > 0,
              let baseFoodSize = Food.Size(volumeWithServing: baseMFPSize, mfpSizes: scrapedSizes)
        else {
            return nil
        }
        
        //MARK: - Configure Food
        let food = baseFood
        food.amount = 1
        
        //TODO: Check that this is now valid to uncomment
        food.servingUnit = .size
        if scrapedSizes.containsWeightBasedSize {
            //TODO: Should this be 1 or baseSize.value?
            food.servingAmount = 1
            food.servingSize = baseFoodSize
        } else {
            food.servingAmount = 0
        }
        
        food.scaleNutrientsBy(scale: (food.amount * baseMFPSize.multiplier))

        food.sizes.append(baseFoodSize)

        //MARK: - Add Sizes
        
        //MARK: serving
        /// add remaining servings or descriptive volumes
        //TODO: Check if this is valid
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            //TODO: Replace isDescriptiveCups call with checking if nameVolumeUnit is filled instead (in all food creators)
//            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
            $0.type == .serving
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .volume, amount: baseFoodSize.amount * baseMFPSize.value, baseFoodSize: baseFoodSize)
        )
        
        
        //MARK: volumeWithServing
        /// Add all remaining `volumeWithServing` sizes
        food.sizes.append(contentsOf: scrapedSizes.dropFirst().filter {
            $0.type == .volumeWithServing
        }.compactMap {
            Food.Size(volumeWithServing: $0, mfpSizes: scrapedSizes)
        })

        food.sizes.append(contentsOf: scrapedSizes.filter {
            $0.type == .servingWithVolume
        }.compactMap {
            Food.Size(servingWithVolume: $0, baseSize: baseFoodSize, mfpSizes: scrapedSizes)
        })

        //MARK: servingWithServing
        food.sizes.append(contentsOf: scrapedSizes.filter {
            $0.type == .servingWithServing
        }.compactMap {
            Food.Size(servingWithServing: $0, baseFoodSize: baseFoodSize, mfpSizes: scrapedSizes)
        })
        
        return food
    }
}
