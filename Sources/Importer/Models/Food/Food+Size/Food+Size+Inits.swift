import Foundation

extension Food.Size {
    
    convenience init?(mfpSize: MFPFood.Size, mfpSizes: [MFPFood.Size]) {
        guard let firstSize = mfpSizes.first else { return nil }
        switch mfpSize.type {
        case .volumeWithServing:
            self.init(volumeWithServing: mfpSize, mfpSizes: mfpSizes)
        case .servingWithWeight:
            self.init(servingWithWeight: mfpSize, firstMFPSize: firstSize)
        case .servingWithVolume:
            guard let firstFoodSize = mfpSizes.firstFoodSize else { return nil }
            self.init(servingWithVolume: mfpSize, firstSize: firstFoodSize, mfpSizes: mfpSizes)
        case .servingWithServing:
            guard let firstFoodSize = mfpSizes.firstFoodSize else { return nil }
            self.init(servingWithServing: mfpSize, baseFoodSize: firstFoodSize, mfpSizes: mfpSizes)
        default:
            return nil
        }
    }
    
    convenience init?(servingWithVolume mfpSize: MFPFood.Size, firstSize: Food.Size, mfpSizes: [MFPFood.Size]) {
        self.init()
        let parsed = mfpSize.name.parsedServingWithVolume
        guard let servingName = parsed.serving?.name else {
            print("Couldn't parse servingWithVolume: \(mfpSize)")
            return nil
        }
        name = servingName
        amountUnit = .size
//        amount = baseScrapedSize.multiplier * mfpSize.multiplier * baseVolume / firstSize.amount
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
        amountSizeUnit = firstSize
    }
    
    convenience init?(servingWithServing mfpSize: MFPFood.Size, baseFoodSize: Food.Size, mfpSizes: [MFPFood.Size]) {
        guard let baseScrapedSize = mfpSizes.first else {
            return nil
        }
        self.init()
        if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
            name = servingName
        } else {
            name = mfpSize.cleanedName
        }
        amountUnit = .size
        amountSizeUnit = baseFoodSize
        
        //TODO: Do this for all other servingWithServings
//            s.amount = firstSize.multiplier * mfpSize.multiplier * baseVolume
        amount = baseScrapedSize.multiplier * mfpSize.multiplier
    }
    
    convenience init?(volumeWithServing mfpSize: MFPFood.Size, mfpSizes: [MFPFood.Size]) {
        
        self.init()
        
        let parsed = mfpSize.name.parsedVolumeWithServing
        guard let servingName = parsed.serving?.name,
              let volumeUnit = parsed.volume?.unit
        else {
            print("Couldn't parse volumeWithServing: \(mfpSize)")
            return nil
        }
        
        //TODO: Do this test outside the initializer so that we can use it to create the firstSize itself
        /// Make sure this isn't a repeat of the first size (with a different quantity)
//        guard servingName.lowercased() != firstSize.name.lowercased() else {
//            return nil
//        }
        
        name = servingName
        nameVolumeUnit = volumeUnit
        amountUnit = mfpSizes.containsWeightBasedSize ? .weight : .serving
        
        quantity = mfpSize.value
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
    }
}
