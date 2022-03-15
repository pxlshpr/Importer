import Foundation

extension Food.Size {
    
    convenience init?(servingWithVolume mfpSize: MFPFood.Size, baseSize: Food.Size, mfpSizes: [MFPFood.Size]) {
        self.init()
        let parsed = mfpSize.name.parsedServingWithVolume
        guard let servingName = parsed.serving?.name else {
            print("Couldn't parse servingWithVolume: \(mfpSize)")
            return nil
        }
        name = servingName
        amountUnitType = .size
//        amount = baseScrapedSize.multiplier * mfpSize.multiplier * baseVolume / baseSize.amount
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
        amountSizeUnit = baseSize
    }
    
    convenience init?(mfpSize: MFPFood.Size, mfpSizes: [MFPFood.Size]) {
        return nil
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
        amountUnitType = .size
        amountSizeUnit = baseFoodSize
        
        //TODO: Do this for all other servingWithServings
//            s.amount = baseSize.multiplier * mfpSize.multiplier * baseVolume
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
        
        //TODO: Do this test outside the initializer so that we can use it to create the baseSize itself
        /// Make sure this isn't a repeat of the first size (with a different quantity)
//        guard servingName.lowercased() != baseSize.name.lowercased() else {
//            return nil
//        }
        
        name = servingName
        nameVolumeUnit = volumeUnit
        amountUnitType = mfpSizes.containsWeightBasedSize ? .weight : .serving
        
        quantity = mfpSize.value
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
    }
}
