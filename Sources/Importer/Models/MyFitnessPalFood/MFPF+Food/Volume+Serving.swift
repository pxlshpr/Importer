import Foundation

extension MyFitnessPalFood {
    
    var foodStartingWithVolumeWithServing: Food? {
        
        /// protect against division by 0 with baseSize.value check
        guard let baseScrapedSize = baseSize, baseScrapedSize.value > 0 else {
            return nil
        }
        
//        let parsed = baseScrapedSize.name.parsedVolumeWithServing
//        guard let servingName = parsed.serving?.name,
//              let volumeUnit = parsed.volume?.unit
//        else {
//            return nil
//        }
        
        //TODO: Next—How are we going to describe Aphrodisi-oats with our system?
        /// 1 serving = 0.33 cup, cooked
        /// BUT
        /// What does 0.33 cup (or 1 cup) cooked = ??
        /// Since it cannot be serving.
        /// Maybe we SHOULD let it be serving based since we don't have a weight?
        /// OR just assign it the volume in the absence of a weight—
        ///     ie. if a weight can't be inferred from the rest of the sizes, then it gets assigned its volume, descriptively (in this case, being 0.33 cups)
        ///         this means that 0.33 cups, cooked = 0.33 cups
        ///         But think about how assigning this in in the form would be
        ///         > User taps "Add size" on serving field
        ///         > User puts in "0.33", "cups", and "cooked"
        ///         > Now do we get them to save it at this point?
        ///
        ///     BETTER YET
        ///         What about if we have an empty serving, so "1 serving" with no serving size
        ///         But we then have a size called "cups, cooked" where we equate that 0.33 of it == 1 serving
        ///         Voila. Then we have 1 Container = 7.3 of that Size. Done!
        //TODO: Comment all these out properly
        
        let food = baseFood
        
        //TODO: Handle this
//        let baseVolume = baseScrapedSize.processedSize.ml(for: baseScrapedSize.value, unit: volumeUnit)
        
        guard let baseFoodSize = Food.Size(volumeWithServing: baseScrapedSize, otherSizes: scrapedSizes) else {
            return nil
        }
        
//        let baseFoodSize = Food.Size()
//        baseFoodSize.name = servingName.capitalized
//        baseFoodSize.amountUnitType = scrapedSizes.containsWeightBasedSize ? .weight : .serving
//        baseFoodSize.nameVolumeUnit = volumeUnit
//        baseFoodSize.quantity = baseScrapedSize.value
//
//        //TODO: Check that this is valid
////        size.amount = baseVolume / baseSize.value
//        baseFoodSize.amount = scrapedSizes.containsWeightBasedSize ? scrapedSizes.baseWeight * baseScrapedSize.multiplier : baseScrapedSize.multiplier
        
        
        //MARK: - Configure Food
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
        food.sizes.append(contentsOf: scrapedSizes.dropFirst().filter { scrapedSize in
            scrapedSize.type == .volumeWithServing
        }.compactMap {
            Food.Size(volumeWithServing: $0, otherSizes: scrapedSizes)
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithVolume
        }.compactMap { scrapedSize -> Food.Size? in
            Food.Size(servingWithVolume: scrapedSize, baseSize: baseFoodSize, sizes: scrapedSizes)
//            let s = Food.Size()
//            let parsed = scrapedSize.name.parsedServingWithVolume
//            guard let servingName = parsed.serving?.name else {
//                print("Couldn't parse servingWithVolume: \(scrapedSize)")
//                return nil
//            }
//            s.name = servingName
//            s.amountUnitType = .size
//            s.amount = baseScrapedSize.multiplier * scrapedSize.multiplier * baseVolume / baseFoodSize.amount
//            s.amountSizeUnit = baseFoodSize
//            return s
        })

        //MARK: servingWithServing
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            if let servingName = scrapedSize.name.parsedServingWithServing.serving?.name {
                s.name = servingName
            } else {
                s.name = scrapedSize.cleanedName
            }
            s.amountUnitType = .size
            s.amountSizeUnit = baseFoodSize
            
            //TODO: Do this for all other servingWithServings
//            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
            s.amount = baseScrapedSize.multiplier * scrapedSize.multiplier
            return s
        })
        
        //MARK: - Scale Nutrients now
        //TODO: Move this to Food configuration if doable before the sizes have been added
        food.scaleNutrientsBy(scale: (food.amount * baseScrapedSize.multiplier))
        return food
    }
}

extension Food.Size {
    
    convenience init?(servingWithVolume scrapedSize: MyFitnessPalFood.ScrapedSize, baseSize: Food.Size, sizes: [MyFitnessPalFood.ScrapedSize]) {
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
    
    convenience init?(scrapedSize: MyFitnessPalFood.ScrapedSize, otherSizes: [MyFitnessPalFood.ScrapedSize]) {
        return nil
    }
    
    convenience init?(volumeWithServing scrapedSize: MyFitnessPalFood.ScrapedSize, otherSizes sizes: [MyFitnessPalFood.ScrapedSize]) {
        
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
