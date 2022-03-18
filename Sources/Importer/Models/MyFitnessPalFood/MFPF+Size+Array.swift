import Foundation

public extension Array where Element == MFPFood.Size {
    
    var containsWeightBasedSize: Bool {
        contains(where: { $0.isWeightBased })
    }
    
    var firstFoodSize: Food.Size? {
        guard let first = first else { return nil }
        return Food.Size(mfpSize: first, mfpSizes: self)
    }
    
    /// Returns the weight of 1x of this food OR 0 if it is not weight based
    var baseWeight: Double {
        //TODO: Consider size.multiplier for size that may be like 1g:0.01x
//        guard let firstSize = first(where: { $0.isWeightBased }) else {
        guard let firstSize = weightSize else {
            return 0
        }
        let parsed: ParseResult
        switch firstSize.type {
        case .weight:
            parsed = firstSize.name.parsedWeight
        case .weightWithVolume:
            parsed = firstSize.name.parsedWeightWithVolume
        case .weightWithServing:
            parsed = firstSize.name.parsedWeightWithServing
        case .servingWithWeight:
            parsed = firstSize.name.parsedServingWithWeight
        default:
            return 0
        }
        guard let weight = parsed.weight?.amount else {
            /// raw weight (like 'g') without an inferred weight within the name—so we use the trueValue of the size
            return firstSize.trueValue
        }
        return weight
    }
    
    //C796CF29
    /// The first density determined in the order that the sizes are presented (as there may be multiple for a given food)
    var density: Density? {
        if let density = densityFromWeightAndVolumeSizes {
            return density
        }
        
        if let density = densityFromDensitySize {
            return density
        }
        
        return nil
        
//        guard let firstSize = self.first else { return nil }
//        
//        /// volumeWithWeight
//        if let size = first(where: { $0.type == .volumeWithWeight }),
//           let volumeUnit = size.name.parsedVolumeWithWeight.volume?.unit,
//           let weightAmount = size.name.parsedVolumeWithWeight.weight?.amount,
//           let weightUnit = size.name.parsedVolumeWithWeight.weight?.unit
//        {
//            /// determine the density of that particular size
//            let volume = size.processedSize.ml(for: size.value, unit: volumeUnit)
//            let weight = firstSize.processedSize.g(for: weightAmount, unit: weightUnit)
//            return Density(volumeAmount: volume, volumeUnit: .mL, weightAmount: weight, weightUnit: .g)
//        }
//        return nil
    }
    
    var densityFromWeightAndVolumeSizes: Density? {
        guard let weightSize = weightSize, let weightUnit = weightSize.weightUnit,
              let volumeSize = volumeSize, let volumeUnit = volumeSize.volumeUnit
        else {
            return nil
        }
        
        /// Scale the lesser size up to match the greatest multiplier
        if weightSize.multiplier > volumeSize.multiplier {
            let volume = (weightSize.multiplier * volumeSize.value)/volumeSize.multiplier
            return Density(volumeAmount: volume, volumeUnit: volumeUnit,
                           weightAmount: weightSize.value, weightUnit: weightUnit)
        } else {
            let weight = (volumeSize.multiplier * weightSize.value)/weightSize.multiplier
            return Density(volumeAmount: volumeSize.value, volumeUnit: volumeUnit,
                           weightAmount: weight, weightUnit: weightUnit)
        }
    }
    
    /// returns the density off a single size (of type `volumeWithServing`, `volumeWithWeight` or `weightWithVolume`
    var densityFromDensitySize: Density? {
        guard let densitySize = densitySize else {
            return nil
        }
        switch densitySize.type {
        case .weightWithVolume:
            guard let volumeAmount = densitySize.volumeAmount,
                  let volumeUnit = densitySize.volumeUnit,
                  let weightUnit = densitySize.weightUnit
            else {
                return nil
            }
            return Density(volumeAmount: volumeAmount,
                           volumeUnit: volumeUnit,
                           weightAmount: densitySize.trueValue,
                           weightUnit: weightUnit)
        case .volumeWithWeight:
            guard let weightAmount = densitySize.weightAmount,
                  let volumeUnit = densitySize.volumeUnit,
                  let weightUnit = densitySize.weightUnit
            else {
                return nil
            }
            return Density(volumeAmount: densitySize.trueValue,
                           volumeUnit: volumeUnit,
                           weightAmount: weightAmount,
                           weightUnit: weightUnit)
        case .volumeWithServing:
            //TODO: Do this when implementing it
            return nil
        default:
            return nil
        }
    }
    
    var densitySize: MFPFood.Size? {
        /// if we only have one density based size
        ///     return that, regardless of whether it has a serving name or not
        guard filter({ $0.hasDensity }).count > 1 else {
            return first(where: { $0.hasDensity })
        }
        
        //TODO: multiple density based sizes
        /// if we have multiple, then first check if they are technically all the same (ie. share the same density and `servingName` if present)
        ///     if so, return that
        /// otherwise check if any of them have no `servingName`
        ///     if so return that
        
        return nil
    }
    
    var weightSize: MFPFood.Size? {
        /// prioritize getting the unit weight (with a `multiplier` of 1x, before returning the first `weight` size in the array)
        guard let unitWeight = first(where: { $0.type == .weight && $0.multiplier == 1 }) else {
            return first(where: { $0.type == .weight })
        }
        return unitWeight
    }
    
//    var firstWeightSize: Size? {
//        sizes.first(where: { $0.type == .weight })
//    }
    
    var volumeSize: MFPFood.Size? {
        if let size = first(where: { $0.type == .volume && $0.multiplier >= 1 }) {
            return size
        } else if let size = first(where: { $0.type == .volume && $0.volumeUnit == .mL }) {
            return size
        } else {
            return first(where: { $0.type == .volume })
        }
    }
}
