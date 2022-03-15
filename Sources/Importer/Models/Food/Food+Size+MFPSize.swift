import Foundation
import PrepUnits

extension Food {
    func importMFPSizes(from sizes: [MFPFood.Size], ofTypes types: [ServingType], withFirstFoodSize firstFoodSize: Food.Size) {
        
        guard let firstSize = sizes.first else { return }
        
        let sizesToAdd = sizes.dropFirst().filter {
            $0.type == .serving
        }
        self.sizes.append(
            contentsOf: MFPFood.createSizes(from: sizesToAdd, unit: .volume, amount: firstFoodSize.amount * firstSize.value, baseFoodSize: firstFoodSize)
        )
        
        //MARK: volumeWithServing
        /// Add all remaining `volumeWithServing` sizes
        self.sizes.append(contentsOf: sizes.dropFirst().filter {
            $0.type == .volumeWithServing
        }.compactMap {
            Food.Size(volumeWithServing: $0, mfpSizes: sizes)
        })
        
        self.sizes.append(contentsOf: sizes.filter {
            $0.type == .servingWithVolume
        }.compactMap {
            Food.Size(servingWithVolume: $0, firstSize: firstFoodSize, mfpSizes: sizes)
        })
        
        //MARK: servingWithServing
        self.sizes.append(contentsOf: sizes.filter {
            $0.type == .servingWithServing
        }.compactMap {
            Food.Size(servingWithServing: $0, baseFoodSize: firstFoodSize, mfpSizes: sizes)
        })

    }
}

extension Food.Size {
    
    convenience init?(servingWithVolume mfpSize: MFPFood.Size, firstSize: Food.Size, mfpSizes: [MFPFood.Size]) {
        self.init()
        let parsed = mfpSize.name.parsedServingWithVolume
        guard let servingName = parsed.serving?.name else {
            print("Couldn't parse servingWithVolume: \(mfpSize)")
            return nil
        }
        name = servingName
        amountUnitType = .size
//        amount = baseScrapedSize.multiplier * mfpSize.multiplier * baseVolume / firstSize.amount
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
        amountSizeUnit = firstSize
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
        amountUnitType = mfpSizes.containsWeightBasedSize ? .weight : .serving
        
        quantity = mfpSize.value
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
    }
}
