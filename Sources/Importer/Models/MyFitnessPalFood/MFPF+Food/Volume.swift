import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithVolume: Food? {
        guard let firstSize = sizes.first, let ml = firstSize.processedSize.ml else {
            return nil
        }
        let food = baseFood
        
        //TODO: Descriptive cups is now invalid
        /// If the first size has format of `cup, shredded` **and** the next size is a weight size
        if firstSize.isDescriptiveCups, let secondSize = secondSize, secondSize.type == .weight, let secondWeight = secondSize.processedSize.g {
            
            /// translates an entry of `1 g - x0.01` to `100g`
            let secondTotal = secondWeight / secondSize.multiplier
            
            let baseWeight = secondTotal * firstSize.multiplier
            
            let size = Food.Size()
            size.name = firstSize.cleanedName.capitalized
            size.amountUnit = .weight
            size.amount = baseWeight / firstSize.value
            food.sizes.append(size)
            
            food.amount = 1
            food.servingValue = firstSize.value
            food.servingUnit = .size
            food.servingSizeUnit = size
            
            /// add remaining non-measurement servings
            let sizesToAdd = sizes.dropFirst().filter {
                $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
            }
            food.sizes.append(contentsOf:
                                MFPFood.createSizes(from: sizesToAdd, unit: .weight, amount: secondTotal, baseFoodSize: size)
            )
            
            food.scaleNutrientsBy(scale: food.amount * firstSize.multiplier)
            
        } else {
            let volume = ml * firstSize.value / firstSize.multiplier

            food.amountUnit = .serving
            food.amount = 1
            
            food.servingUnit = .volume
            food.servingValue = firstSize.value / firstSize.multiplier
            food.servingVolumeUnit = firstSize.cleanedName.parsedVolume.volume?.unit?.volumeUserUnit
            
            //TODO: Do this for weight too
            /// if any sizes indicate a density
            
            if let density = sizes.density {
                food.density = density
                
                //TODO: Density
                let densityVolume = density.volumeAmount
                let densityWeight = density.weightAmount

                //TODO: Density
                let weight = volume * densityWeight / densityVolume

                let sizesToAdd = sizes.dropFirst().filter {
                    $0.type != .weight && $0.type != .volume
                }
//                .removingSizesWithDifferentDensityToBaseSize()
//                .filter { sizeToAdd in
//                    /// filter out other sizes with a different density
//                    if let sizeDensity = sizeToAdd.density, let foodDensity = food.density, sizeDensity != foodDensity {
//                        return false
//                    }
//
//                    /// filter out sizes with the same ratio/multiplier and volumeUnit
////                    if sizeToAdd.multiplier == firstSize.multiplier,
////                       let volumeUnit = sizeToAdd.volumeUnit,
////                        {
////                        return false
////                    }
//
//                    /// keep any that don't have densities
//                    return true
//                }
                
                food.sizes.append(
                    contentsOf: MFPFood.createSizes(
                        from: sizesToAdd, unit: .volume, amount: volume
                    )
                )

                
//            }
            
//            if let volumeWithWeightSize = sizes.first(where: { $0.type == .volumeWithWeight }),
//               let volumeUnit = volumeWithWeightSize.name.parsedVolumeWithWeight.volume?.unit,
//               let weightAmount = volumeWithWeightSize.name.parsedVolumeWithWeight.weight?.amount,
//               let weightUnit = volumeWithWeightSize.name.parsedVolumeWithWeight.weight?.unit
//            {
//
//                /// determine the density of that particular size
//                food.densityVolume = volumeWithWeightSize.processedSize.ml(for: volumeWithWeightSize.value, unit: volumeUnit)
//                food.densityWeight = firstSize.processedSize.g(for: weightAmount, unit: weightUnit)

//                let weight = volume * food.densityWeight / food.densityVolume
                                
//                /// create the food based on weight
//                food.unit = .g
//                food.amount = weight
//                food.servingAmount = 0
                
                
//                let sizesToAdd = sizes.dropFirst().filter {
//                    $0.type != .weight && $0.type != .volume
//                }.filter { sizeToAdd in
//                    /// filter out other sizes with a different density
//                    if let sizeDensity = sizeToAdd.density, let foodDensity = food.density, sizeDensity != foodDensity {
//                        return false
//                    }
//
//                    /// filter out sizes with the same ratio/multiplier and volumeUnit
//                    if sizeToAdd.multiplier == firstSize.multiplier,
//                       let sizeToAddVolumeUnit = sizeToAdd.volumeUnit,
//                       sizeToAddVolumeUnit == volumeUnit {
//                        return false
//                    }
//
//                    /// keep any that don't have densities
//                    return true
//                }
//
//                food.sizes.append(
//                    contentsOf: MFPFood.createSizes(
//                        from: sizesToAdd, unit: .g, amount: weight
//                    )
//                )
            } else {
                let sizesToAdd = sizes.dropFirst().filter {
                    $0.type != .weight && $0.type != .volume
                }
                food.sizes.append(
                    contentsOf: MFPFood.createSizes(
                        from: sizesToAdd, unit: .volume, amount: volume
                    )
                )
            }
            food.scaleNutrientsBy(scale: food.amount / volume)
        }
        
        return food
    }
}

public extension Array where Element == MFPFood.Size {
    
//    func removingSizesWithDifferentDensityToBaseSize() -> [Element] {
//        return filter { size in
//            if let sizeDensity = size.density,
//               let baseDensity = density,
//               sizeDensity != baseDensity
//            {
//                /// has a density that is different to baseDensity, so do not include it
//                return false
//            }
//
//            /// either has no density or matches density of baseDensity, so include it
//            return true
//        }
//    }
//
//    mutating func removeSizesWithDifferentDensityToBaseSize() {
//        self = self.removingSizesWithDifferentDensityToBaseSize()
//    }
    
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

extension VolumeUnit {
    
    var volumeUserUnit: VolumeUserUnit? {
        switch self {
        case .mL:
            return VolumeMilliliterUserUnit.ml
        case .teaspoon:
            return VolumeTeaspoonUserUnit.teaspoonMetric
        case .tablespoon:
            return VolumeTablespoonUserUnit.tablespoonMetric
        case .fluidOunce:
            return VolumeFluidOunceUserUnit.fluidOunceUSNutritionLabeling
        case .cup:
            return VolumeCupUserUnit.cupUSLegal
        case .pint:
            return VolumePintUserUnit.pintImperial
        case .quart:
            return VolumeQuartUserUnit.quartImperial
        case .gallon:
            return VolumeGallonUserUnit.gallonUSLiquid
        }
    }
}
