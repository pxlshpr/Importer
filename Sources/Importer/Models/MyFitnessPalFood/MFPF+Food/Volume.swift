import Foundation
import PrepUnits

extension MyFitnessPalFood {
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
            size.unit = .g
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
                                createSizes(from: sizesToAdd, unit: .g, amount: secondTotal, baseFoodSize: size)
            )
            
            food.scaleNutrientsBy(scale: food.amount * baseSize.multiplier)
            
        } else {
            let volume = ml * baseSize.value / baseSize.multiplier

            food.unit = .serving
            food.amount = 1
            
            food.servingUnit = .mL
            food.servingAmount = baseSize.value / baseSize.multiplier
            food.servingVolumeUnit = baseSize.cleanedName.parsedVolume.volume?.unit?.volumeUserUnit
            
            //TODO: Do this for weight too
            /// if any sizes indicate a density
            
            if let baseDensity = scrapedSizes.baseDensity {
                food.density = baseDensity
                let weight = volume * food.densityWeight / food.densityVolume

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
                        from: sizesToAdd, unit: .g, amount: weight
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
                        from: sizesToAdd, unit: .mL, amount: volume
                    )
                )
            }
            food.scaleNutrientsBy(scale: food.amount / volume)
        }
        
        return food
    }
}

public extension Array where Element == MyFitnessPalFood.ScrapedSize {
    
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
}

extension MyFitnessPalFood.ScrapedSize {
    
}


//C796CF29
extension Array where Iterator.Element == MyFitnessPalFood.ScrapedSize
{
    
    var baseSize: MyFitnessPalFood.ScrapedSize? {
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
