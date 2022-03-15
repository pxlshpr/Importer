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
//            if let servingName = scrapedSize.name.parsedServingWithServing.serving?.name {
//                s.name = servingName
//            } else {
//                s.name = scrapedSize.cleanedName
//            }
//            s.amountUnitType = .size
//            s.amountSizeUnit = baseFoodSize
//
//            //TODO: Do this for all other servingWithServings
////            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
//            s.amount = baseScrapedSize.multiplier * scrapedSize.multiplier
//            return s
        })
        
        //MARK: - Scale Nutrients now
        //TODO: Move this to Food configuration if doable before the sizes have been added
        food.scaleNutrientsBy(scale: (food.amount * baseScrapedSize.multiplier))
        return food
    }
}

extension Food.Size {
    
    convenience init?(servingWithVolume scrapedSize: MFPFood.ScrapedSize, baseSize: Food.Size, sizes: [MFPFood.ScrapedSize]) {
        self.init()
        let parsed = scrapedSize.name.parsedServingWithVolume
        guard let servingName = parsed.serving?.name else {
            print("Couldn't parse servingWithVolume: \(scrapedSize)")
            return nil
        }
        name = servingName
        amountUnitType = .size
//        amount = baseScrapedSize.multiplier * scrapedSize.multiplier * baseVolume / baseSize.amount
        amount = sizes.containsWeightBasedSize ? sizes.baseWeight * scrapedSize.multiplier : scrapedSize.multiplier
        amountSizeUnit = baseSize
    }
    
    convenience init?(scrapedSize: MFPFood.ScrapedSize, otherSizes: [MFPFood.ScrapedSize]) {
        return nil
    }
    
    convenience init?(servingWithServing scrapedSize: MFPFood.ScrapedSize, baseFoodSize: Food.Size, otherSizes sizes: [MFPFood.ScrapedSize]) {
        guard let baseScrapedSize = sizes.first else {
            return nil
        }
        self.init()
        if let servingName = scrapedSize.name.parsedServingWithServing.serving?.name {
            name = servingName
        } else {
            name = scrapedSize.cleanedName
        }
        amountUnitType = .size
        amountSizeUnit = baseFoodSize
        
        //TODO: Do this for all other servingWithServings
//            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
        amount = baseScrapedSize.multiplier * scrapedSize.multiplier
    }
    convenience init?(volumeWithServing scrapedSize: MFPFood.ScrapedSize, otherSizes sizes: [MFPFood.ScrapedSize]) {
        
        self.init()
        
        let parsed = scrapedSize.name.parsedVolumeWithServing
        guard let servingName = parsed.serving?.name,
              let volumeUnit = parsed.volume?.unit
        else {
            print("Couldn't parse volumeWithServing: \(scrapedSize)")
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
        
        quantity = scrapedSize.value
        amount = sizes.containsWeightBasedSize ? sizes.baseWeight * scrapedSize.multiplier : scrapedSize.multiplier
    }
}
