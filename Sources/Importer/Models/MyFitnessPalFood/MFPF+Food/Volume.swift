import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithVolume: Food? {
        guard let baseSize = baseSize, let ml = baseSize.processedSize.ml else {
            return nil
        }
        let food = baseFood
        
        /// If the base size has format of `cup, shredded` **and** the next size is a weight size
        if baseSize.isDescriptiveCups, let secondSize = secondSize, secondSize.type == .weight, let secondWeight = secondSize.processedSize.g {
            
            /// translates an entry of `1 g - x0.01` to `100g`
            let secondTotal = secondWeight / secondSize.multiplier
            
            let baseWeight = secondTotal * baseSize.multiplier
            
            let size = Food.Size()
            size.name = baseSize.cleanedName.capitalized
            size.amountUnitType = .weight
            size.amount = baseWeight / baseSize.value
            food.sizes.append(size)
            
            food.setAmount(basedOn: baseWeight)
//            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
            food.servingAmount = baseSize.value
            food.servingUnit = .size
            food.servingSize = size
            
            /// add remaining non-measurement servings
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
            }
            food.sizes.append(contentsOf:
                                createSizes(from: sizesToAdd, unit: .weight, amount: secondTotal, baseFoodSize: size)
            )
            
            food.scaleNutrientsBy(scale: food.amount * baseSize.multiplier)
            
        } else {
            let volume = ml * baseSize.value / baseSize.multiplier

            food.unit = .serving
            food.amount = 1
            
            food.servingUnit = .volume
            food.servingAmount = baseSize.value / baseSize.multiplier
            food.servingVolumeUnit = baseSize.cleanedName.parsedVolume.volume?.unit?.volumeUserUnit
            
            //TODO: Do this for weight too
            /// if any sizes indicate a density
            
            if let baseDensity = scrapedSizes.baseDensity {
                food.density = baseDensity
                
                let densityVolume = baseDensity.volume
                let densityWeight = baseDensity.weight

                //TODO: Density
                let weight = volume * densityWeight / densityVolume

                let sizesToAdd = scrapedSizes.dropFirst().filter {
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
////                    if sizeToAdd.multiplier == baseSize.multiplier,
////                       let volumeUnit = sizeToAdd.volumeUnit,
////                        {
////                        return false
////                    }
//
//                    /// keep any that don't have densities
//                    return true
//                }
                
                food.sizes.append(
                    contentsOf: createSizes(
                        from: sizesToAdd, unit: .volume, amount: volume
                    )
                )

                
//            }
            
//            if let volumeWithWeightSize = scrapedSizes.first(where: { $0.type == .volumeWithWeight }),
//               let volumeUnit = volumeWithWeightSize.name.parsedVolumeWithWeight.volume?.unit,
//               let weightAmount = volumeWithWeightSize.name.parsedVolumeWithWeight.weight?.amount,
//               let weightUnit = volumeWithWeightSize.name.parsedVolumeWithWeight.weight?.unit
//            {
//
//                /// determine the density of that particular size
//                food.densityVolume = volumeWithWeightSize.processedSize.ml(for: volumeWithWeightSize.value, unit: volumeUnit)
//                food.densityWeight = baseSize.processedSize.g(for: weightAmount, unit: weightUnit)

//                let weight = volume * food.densityWeight / food.densityVolume
                                
//                /// create the food based on weight
//                food.unit = .g
//                food.amount = weight
//                food.servingAmount = 0
                
                
//                let sizesToAdd = scrapedSizes.dropFirst().filter {
//                    $0.type != .weight && $0.type != .volume
//                }.filter { sizeToAdd in
//                    /// filter out other sizes with a different density
//                    if let sizeDensity = sizeToAdd.density, let foodDensity = food.density, sizeDensity != foodDensity {
//                        return false
//                    }
//
//                    /// filter out sizes with the same ratio/multiplier and volumeUnit
//                    if sizeToAdd.multiplier == baseSize.multiplier,
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
//                    contentsOf: createSizes(
//                        from: sizesToAdd, unit: .g, amount: weight
//                    )
//                )
            } else {
                let sizesToAdd = scrapedSizes.dropFirst().filter {
                    $0.type != .weight && $0.type != .volume
                }
                food.sizes.append(
                    contentsOf: createSizes(
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
    
    func removingSizesWithDifferentDensityToBaseSize() -> [Element] {
        return filter { size in
            if let sizeDensity = size.density,
               let baseDensity = baseDensity,
               sizeDensity != baseDensity
            {
                /// has a density that is different to baseDensity, so do not include it
                return false
            }
            
            /// either has no density or matches density of baseDensity, so include it
            return true
        }
    }

    mutating func removeSizesWithDifferentDensityToBaseSize() {
        self = self.removingSizesWithDifferentDensityToBaseSize()
    }
    
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
}

//C796CF29
extension Array where Iterator.Element == MFPFood.Size
{
    
    var baseSize: MFPFood.Size? {
        first
    }
    
    /// The first density determined in the order that the sizes are presented (as there may be multiple for a given food)
    var baseDensity: Density? {
        guard let baseSize = self.first else { return nil }
        
        /// volumeWithWeight
        if let size = first(where: { $0.type == .volumeWithWeight }),
           let volumeUnit = size.name.parsedVolumeWithWeight.volume?.unit,
           let weightAmount = size.name.parsedVolumeWithWeight.weight?.amount,
           let weightUnit = size.name.parsedVolumeWithWeight.weight?.unit
        {
            /// determine the density of that particular size
            let volume = size.processedSize.ml(for: size.value, unit: volumeUnit)
            let weight = baseSize.processedSize.g(for: weightAmount, unit: weightUnit)
            return Density(volume: volume, weight: weight)
        }
        return nil
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
