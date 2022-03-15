import Foundation

extension MFPFood {
    
    var foodStartingWithVolumeWithServing: Food? {
        
        /// protect against division by 0 with baseSize.value check
        guard let baseScrapedSize = baseSize,
              baseScrapedSize.value > 0,
              let baseFoodSize = Food.Size(volumeWithServing: baseScrapedSize, otherSizes: scrapedSizes)
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
            contentsOf: createSizes(from: sizesToAdd, unit: .volume, amount: baseFoodSize.amount * baseScrapedSize.value, baseFoodSize: baseFoodSize)
        )
        
        
        //MARK: volumeWithServing
        /// Add all remaining `volumeWithServing` sizes
        food.sizes.append(contentsOf: scrapedSizes.dropFirst().filter {
            $0.type == .volumeWithServing
        }.compactMap {
            Food.Size(volumeWithServing: $0, otherSizes: scrapedSizes)
        })

        food.sizes.append(contentsOf: scrapedSizes.filter {
            $0.type == .servingWithVolume
        }.compactMap {
            Food.Size(servingWithVolume: $0, baseSize: baseFoodSize, sizes: scrapedSizes)
        })

        //MARK: servingWithServing
        food.sizes.append(contentsOf: scrapedSizes.filter {
            $0.type == .servingWithServing
        }.compactMap {
            Food.Size(servingWithServing: $0, baseFoodSize: baseFoodSize, otherSizes: scrapedSizes)
//            let s = Food.Size()
//            if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
//                s.name = servingName
//            } else {
//                s.name = mfpSize.cleanedName
//            }
//            s.amountUnitType = .size
//            s.amountSizeUnit = baseFoodSize
//
//            //TODO: Do this for all other servingWithServings
////            s.amount = baseSize.multiplier * mfpSize.multiplier * baseVolume
//            s.amount = baseScrapedSize.multiplier * mfpSize.multiplier
//            return s
        })
        
        //MARK: - Scale Nutrients now
        //TODO: Move this to Food configuration if doable before the sizes have been added
        food.scaleNutrientsBy(scale: (food.amount * baseScrapedSize.multiplier))
        return food
    }
}

extension Food.Size {
    
    convenience init?(servingWithVolume mfpSize: MFPFood.Size, baseSize: Food.Size, sizes: [MFPFood.Size]) {
        self.init()
        let parsed = mfpSize.name.parsedServingWithVolume
        guard let servingName = parsed.serving?.name else {
            print("Couldn't parse servingWithVolume: \(mfpSize)")
            return nil
        }
        name = servingName
        amountUnitType = .size
//        amount = baseScrapedSize.multiplier * mfpSize.multiplier * baseVolume / baseSize.amount
        amount = sizes.containsWeightBasedSize ? sizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
        amountSizeUnit = baseSize
    }
    
    convenience init?(mfpSize: MFPFood.Size, otherSizes: [MFPFood.Size]) {
        return nil
    }
    
    convenience init?(servingWithServing mfpSize: MFPFood.Size, baseFoodSize: Food.Size, otherSizes sizes: [MFPFood.Size]) {
        guard let baseScrapedSize = sizes.first else {
            return nil
        }
        self.init()
        if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
            name = servingName
        } else {
            name = mfpSize.cleanedName
        }
        amountUnitType = .size
        amountSizeUnit = baseFoodSize
        
        //TODO: Do this for all other servingWithServings
//            s.amount = baseSize.multiplier * mfpSize.multiplier * baseVolume
        amount = baseScrapedSize.multiplier * mfpSize.multiplier
    }
    convenience init?(volumeWithServing mfpSize: MFPFood.Size, otherSizes sizes: [MFPFood.Size]) {
        
        self.init()
        
        let parsed = mfpSize.name.parsedVolumeWithServing
        guard let servingName = parsed.serving?.name,
              let volumeUnit = parsed.volume?.unit
        else {
            print("Couldn't parse volumeWithServing: \(mfpSize)")
            return nil
        }
        
        //TODO: Do this test outside the initializer so that we can use it to create the baseSize itself
        /// Make sure this isn't a repeat of the first size (with a different quantity)
//        guard servingName.lowercased() != baseSize.name.lowercased() else {
//            return nil
//        }
        
        name = servingName
        nameVolumeUnit = volumeUnit
        amountUnitType = sizes.containsWeightBasedSize ? .weight : .serving
        
        quantity = mfpSize.value
        amount = sizes.containsWeightBasedSize ? sizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
    }
}
