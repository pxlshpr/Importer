import Foundation

extension MyFitnessPalFood {
    
    var containsWeightBasedSize: Bool {
        scrapedSizes.contains(where: { $0.isWeightBased })
    }
    
    /// Returns the weight of 1x of this food OR 0 if it is not weight based
    var baseWeight: Double {
        //TODO: Write this
        return 0
    }
    
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
        food.servingAmount = baseSize.value
        food.servingUnit = .size
        
        //TODO: Handle this
        let baseVolume = baseSize.processedSize.ml(for: baseSize.value, unit: volumeUnit)
        
        let size = Food.Size()
        size.name = servingName.capitalized
        size.amountUnitType = containsWeightBasedSize ? .weight : .serving
        size.nameVolumeUnit = volumeUnit
        size.quantity = baseSize.value
        
        //TODO: Check that this is valid
//        size.amount = baseVolume / baseSize.value
        size.amount = containsWeightBasedSize ? baseWeight * baseSize.multiplier : baseSize.multiplier
        
        //TODO: Change this
        food.setAmount(basedOn: baseVolume)
        
        //TODO: Check that this is now valid to uncomment
//        food.servingSize = size
        
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
            s.amountUnitType = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume / size.amount
            s.amountSizeUnit = size
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
            s.amountUnitType = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
            s.amountSizeUnit = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
}
