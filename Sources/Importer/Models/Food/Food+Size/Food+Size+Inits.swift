import Foundation
import SwiftSugar

extension String {
    var formattedForSize: String {
        cleaned.capitalizingFirstLetter()
    }
}
extension Food.Size {
    
    convenience init?(mfpSize: MFPFood.Size, mfpSizes: [MFPFood.Size]) {
        guard let firstSize = mfpSizes.first else { return nil }
        switch mfpSize.type {
        case .serving:
            self.init(serving: mfpSize, mfpSizes: mfpSizes)
        case .volumeWithServing:
            self.init(volumeWithServing: mfpSize, mfpSizes: mfpSizes)
        case .volumeWithWeight:
            self.init(volumeWithWeight: mfpSize)
        case .servingWithWeight:
            self.init(servingWithWeight: mfpSize, firstMFPSize: firstSize)
        case .weightWithServing:
            self.init(weightWithServing: mfpSize, firstMFPSize: firstSize)
        case .servingWithVolume:
            self.init(servingWithVolume: mfpSize, firstMFPSize: firstSize)
        case .servingWithServing:
            guard let firstFoodSize = mfpSizes.firstFoodSize else { return nil }
            self.init(servingWithServing: mfpSize, firstFoodSize: firstFoodSize, mfpSizes: mfpSizes)
        default:
            return nil
        }
    }
    
    convenience init?(serving mfpSize: MFPFood.Size, mfpSizes: [MFPFood.Size]) {
        self.init()

        name = mfpSize.name.formattedForSize
        
        if name.isServingOfPlainServing, let servingName = name.parsedServingWithServing.serving?.name {
            name = servingName.formattedForSize
        }

        if let weightSize = mfpSizes.weightSize {
            /// check if we have a weight size to base this off
            amountUnit = .weight
            amountWeightUnit = weightSize.weightUnit
            amount = (weightSize.value * mfpSize.multiplier) / weightSize.multiplier / mfpSize.value
        } else if let volumeSize = mfpSizes.volumeSize {
            /// or a volume size
            amountUnit = .volume
            amountVolumeUnit = volumeSize.volumeUnit
            amount = (volumeSize.value * mfpSize.multiplier) / volumeSize.multiplier / mfpSize.value
        } else {
            /// if neither weight or volume sizes are present—express it in terms of 'servings'
            amountUnit = .serving
            amount = 1.0/mfpSize.trueValue
        }
    }

    convenience init?(weightWithServing mfpSize: MFPFood.Size, firstMFPSize: MFPFood.Size) {
        guard let servingName = mfpSize.parsed?.serving?.name,
              let servingAmount = mfpSize.parsed?.serving?.amount
        else {
            return nil
        }
        
        self.init()
        name = servingName.formattedForSize
        
        guard mfpSize.value > 0 else {
            return
        }
        amount = mfpSize.value / mfpSize.multiplier / servingAmount
        amountUnit = .weight
        amountWeightUnit = mfpSize.weightUnit
    }
    
    convenience init?(servingWithWeight mfpSize: MFPFood.Size, firstMFPSize: MFPFood.Size) {
        guard let servingName = mfpSize.parsed?.serving?.name,
              let weightAmount = mfpSize.parsed?.weight?.amount
        else {
            return nil
        }
        
        self.init()
        name = servingName.formattedForSize
        
        if firstMFPSize.type.startsWithWeight {
            /// for sizes like "Container (2250g) = 72x"—mark it as being 72 servings as opposed to 2.5 kg (as the weight gets inferred in the description either way)
            amount = mfpSize.multiplier
            amountUnit = .serving
        } else {
            guard mfpSize.value > 0 else {
                return
            }
            amount = weightAmount / mfpSize.value * mfpSize.multiplier
            amountUnit = .weight
            amountWeightUnit = mfpSize.weightUnit
        }
    }
    
    convenience init?(servingWithVolume mfpSize: MFPFood.Size, firstMFPSize: MFPFood.Size) {
        guard let servingName = mfpSize.parsed?.serving?.name,
              let volumeAmount = mfpSize.parsed?.volume?.amount
        else {
            return nil
        }

        self.init()
        name = servingName.formattedForSize
        
        if firstMFPSize.type.startsWithVolume {
            /// for sizes like "Container (1000ml) = 10x"—mark it as being 10 servings as opposed to 1000 ml (as the volume gets inferred in the description either way)
            amount = mfpSize.multiplier
            amountUnit = .serving
        } else {
            amount = volumeAmount
            amountUnit = .volume
            amountVolumeUnit = mfpSize.volumeUnit
        }
    }
    
    convenience init?(servingWithServing mfpSize: MFPFood.Size, firstFoodSize: Food.Size, mfpSizes: [MFPFood.Size]) {
        guard let baseScrapedSize = mfpSizes.first else {
            return nil
        }
        self.init()
        if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
            name = servingName.formattedForSize
        } else {
            name = mfpSize.name.formattedForSize
        }
        amountUnit = .size
        amountSizeUnit = firstFoodSize
        
        amount = baseScrapedSize.multiplier * mfpSize.multiplier * baseScrapedSize.value / mfpSize.value
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
        
        name = servingName.formattedForSize
        nameVolumeUnit = volumeUnit
        amountUnit = mfpSizes.containsWeightBasedSize ? .weight : .serving
        amountWeightUnit = mfpSizes.weightSize?.weightUnit
        
        quantity = mfpSize.value
        amount = mfpSizes.containsWeightBasedSize ? mfpSizes.baseWeight * mfpSize.multiplier : mfpSize.multiplier
    }
    
    convenience init?(volumeWithWeight mfpSize: MFPFood.Size) {
        guard let servingName = mfpSize.parsed?.serving?.name,
              let volumeUnit = mfpSize.volumeUnit,
              let weightUnit = mfpSize.weightUnit,
              let weightAmount = mfpSize.weightAmount
        else {
            return nil
        }
        self.init()
        
        name = servingName.formattedForSize
        nameVolumeUnit = volumeUnit
        amountUnit = .weight
        amountWeightUnit = weightUnit
        
        quantity = 1
        amount = weightAmount
    }    
}
