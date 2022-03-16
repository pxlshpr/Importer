import Foundation

public extension Array where Element == MFPFood.Size {
    
    var containsWeightBasedSize: Bool {
        contains(where: { $0.isWeightBased })
    }
    
    /// Returns the weight of 1x of this food OR 0 if it is not weight based
    var baseWeight: Double {
        //TODO: Consider size.multiplier for size that may be like 1g:0.01x
        guard let size = first(where: { $0.isWeightBased }) else {
            return 0
        }
        let parsed: ParseResult
        switch size.type {
        case .weight:
            parsed = size.name.parsedWeight
        case .weightWithVolume:
            parsed = size.name.parsedWeightWithVolume
        case .weightWithServing:
            parsed = size.name.parsedWeightWithServing
        case .servingWithWeight:
            parsed = size.name.parsedServingWithWeight
        default:
            return 0
        }
        guard let weight = parsed.weight?.amount else {
            return 0
        }
        return weight
    }
    
    //C796CF29
    /// The first density determined in the order that the sizes are presented (as there may be multiple for a given food)
    var density: Density? {
        //TODO: Go through the and see if we have both a raw weight and a raw volume first—then use the multipliers to express the density
        //TODO: If they're both not found, then look for a volumeWithWeight
        //
        if let density = densityFromWeightAndVolumeSizes {
            return density
        }
        
        return nil
        
        guard let firstSize = self.first else { return nil }
        
        /// volumeWithWeight
        if let size = first(where: { $0.type == .volumeWithWeight }),
           let volumeUnit = size.name.parsedVolumeWithWeight.volume?.unit,
           let weightAmount = size.name.parsedVolumeWithWeight.weight?.amount,
           let weightUnit = size.name.parsedVolumeWithWeight.weight?.unit
        {
            /// determine the density of that particular size
            let volume = size.processedSize.ml(for: size.value, unit: volumeUnit)
            let weight = firstSize.processedSize.g(for: weightAmount, unit: weightUnit)
            return Density(volumeAmount: volume, volumeUnit: .mL, weightAmount: weight, weightUnit: .g)
        }
        return nil
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
    
    var weightSize: MFPFood.Size? {
        /// prioritize getting the unit weight (with a `multiplier` of 1x, before returning the first `weight` size in the array)
        guard let unitWeight = first(where: { $0.type == .weight && $0.multiplier == 1 }) else {
            return first(where: { $0.type == .weight })
        }
        return unitWeight
    }
    
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
