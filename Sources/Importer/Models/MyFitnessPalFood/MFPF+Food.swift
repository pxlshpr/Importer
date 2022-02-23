import Foundation

extension MyFitnessPalFood {
    var food: Food? {
        guard let firstType = firstType else {
            print("No firstType from: \(scrapedSizes.count) sizes")
            return nil
        }
        switch firstType {
        case .weight:
            return foodStartingWithWeight
        case .volume:
            return foodStartingWithVolume
        case .serving:
            return foodStartingWithServing
        case .servingWithWeight:
            return foodStartingWithServingWithWeight
        case .servingWithVolume:
            return foodStartingWithServingWithVolume
        case .weightWithServing:
            return foodStartingWithWeightWithServing
        case .volumeWithWeight:
            return foodStartingWithVolumeWithWeight
        case .weightWithVolume:
            return foodStartingWithWeightWithVolume
        default:
            return Food()
        }
    }
    
    var baseFood: Food {
        let food = Food()
        food.name = cleanedName
        food.brand = cleanedBrand
        food.unit = .serving
        food.energy = energy ?? 0
        food.carbohydrate = carb ?? 0
        food.fat = fat ?? 0
        food.protein = protein ?? 0
        return food
    }
    
    //MARK: - Food Creators
    
    var foodStartingWithWeight: Food? {
        guard let baseSize = baseSize, let g = baseSize.processedSize.g else {
            return nil
        }
        
        let food = baseFood
        //TODO: Make food volume based for those starting with volume too
        food.unit = .g
        food.servingUnit = .g
        
        //TODO: We weren't correctly considering the multiplier—so check all other cases for this. Check the weight being set correctly, then used correctly in sizes and when scaling nutrients
        let weight = g * baseSize.value / baseSize.multiplier
        
        //TODO: Try setting amount to weight and not setting a serving value
        food.amount = weight
        food.servingAmount = 0
        
//        food.setAmount(basedOn: weight)
//        food.servingAmount = weight
        
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type != .weight && $0.type != .volume
        }
        food.sizes.append(
            contentsOf: createSizes(
//                from: sizesToAdd, unit: .g, amount: (g * baseSize.value)
                from: sizesToAdd, unit: .g, amount: weight
            )
        )
        
//        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        food.scaleNutrientsBy(scale: food.amount * baseSize.multiplier)
        return food
    }
    
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
            
        } else {
            let volume = ml * baseSize.value / baseSize.multiplier
            food.unit = .mL
            food.amount = volume
            food.servingAmount = 0
            
//            food.setAmount(basedOn: volume)
//            food.servingAmount = volume
//            food.servingUnit = .mL
            
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type != .weight && $0.type != .volume
            }
            food.sizes.append(
                contentsOf: createSizes(
                    from: sizesToAdd, unit: .mL, amount: volume
                )
            )
        }
        
        food.scaleNutrientsBy(scale: food.amount * baseSize.multiplier)
        return food
    }
    
    var foodStartingWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        let food = baseFood
        food.servingUnit = .size
        food.servingAmount = baseSize.value
        
        let size = Food.Size()
        size.name = baseSize.cleanedName.capitalized
        
        let total: Double
        /// check if we have any weight size
        if let weightSize = firstWeightSize, let weight = weightSize.processedSize.g {
            /// translates an entry of `1 g - x0.01` to `100g`
            total = weight / weightSize.multiplier
            let baseWeight = total * baseSize.multiplier
            
            food.setAmount(basedOn: baseWeight)
//            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
            size.unit = .g
            size.amount = baseWeight / baseSize.value
            
            food.sizes.append(size)
            food.servingSize = size
            
        } else {
            food.amount = 1
            size.unit = .serving
            size.amount = 1.0/baseSize.value
            
            total = baseSize.multiplier
            
            food.sizes.append(size)
            food.servingSize = size
        }
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(contentsOf:
                            createSizes(from: sizesToAdd, unit: size.unit, amount: total, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let remainingSize = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                remainingSize.name = parsed.serving.capitalized
            } else {
                remainingSize.name = scrapedSize.cleanedName.capitalized
            }
            remainingSize.unit = .size
            remainingSize.amount = total * scrapedSize.multiplier * baseSize.value
            remainingSize.size = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    var foodStartingWithServingWithWeight: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0, let parsed = ServingType.parseServingWithWeight(baseSize.name)
        else {
            return nil
        }
        let food = baseFood
        food.servingAmount = baseSize.value
        food.servingUnit = .size
        
        let size = Food.Size()
        size.name = parsed.name.cleaned.capitalized
        size.unit = .g
        size.amount = baseSize.processedSize.g(for: parsed.value, unit: parsed.unit) / baseSize.value
        
        food.setAmount(basedOn: size.amount)
//        food.amount = size.amount < 100 ? 100 / size.amount : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups) || $0.type == .servingWithVolume || $0.type == .servingWithWeight
        }
        food.sizes.append(contentsOf:
                            createSizes(from: sizesToAdd, unit: .g, amount: size.amount, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let remainingSize = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                remainingSize.name = parsed.serving.capitalized
            } else {
                remainingSize.name = scrapedSize.cleanedName.capitalized
            }
            remainingSize.unit = .size
            remainingSize.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
            remainingSize.size = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    var foodStartingWithServingWithVolume: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0, let parsed = ServingType.parseServingWithVolume(baseSize.name)
        else {
            return nil
        }
        let food = baseFood
        food.servingAmount = baseSize.value
        food.servingUnit = .size
        
        let size = Food.Size()
        size.name = parsed.name.capitalized
        size.unit = .mL
        size.amount = baseSize.processedSize.ml(for: parsed.value, unit: parsed.unit) / baseSize.value
        
        food.setAmount(basedOn: size.amount)
//        food.amount = size.amount < 100 ? 100 / size.amount : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(contentsOf:
                            createSizes(from: sizesToAdd, unit: .mL, amount: size.amount, baseFoodSize: size)
        )
        
        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let remainingSize = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                remainingSize.name = parsed.serving.capitalized
            } else {
                remainingSize.name = scrapedSize.cleanedName.capitalized
            }
            remainingSize.unit = .size
            remainingSize.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
            remainingSize.size = size
            return remainingSize
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    var foodStartingWithWeightWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0,
                let parsed = ServingType.parseWeightWithServing(baseSize.name)
        else {
            return nil
        }
        let food = baseFood
        food.servingAmount = parsed.servingValue
        food.servingUnit = .size
        
        let baseWeight = baseSize.processedSize.g(for: baseSize.value, unit: parsed.unit)
        
        let size = Food.Size()
        size.name = parsed.servingName.capitalized
        size.unit = .g
        size.amount = baseWeight / parsed.servingValue
        
        food.setAmount(basedOn: baseWeight)
//        food.amount = baseWeight < 100 ? 100 / baseWeight : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .g, amount: size.amount * parsed.servingValue, baseFoodSize: size)
        )

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithWeight
        }.compactMap { scrapedSize -> Food.Size? in
            let s = Food.Size()
            guard let parsed = ServingType.parseServingWithWeight(scrapedSize.name) else {
                print("Couldn't parse servingWithWeight: \(scrapedSize)")
                return nil
            }
            s.name = parsed.name
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseWeight / size.amount
            s.size = size
            return s
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                s.name = parsed.serving
            } else {
                s.name = scrapedSize.cleanedName
            }
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseWeight
            s.size = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    //TODO: needs testing
    var foodStartingWithVolumeWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0,
                let parsed = ServingType.parseVolumeWithServing(baseSize.name)
        else {
            return nil
        }
        let food = baseFood
        food.servingAmount = parsed.servingValue
        food.servingUnit = .size
        
        let baseVolume = baseSize.processedSize.ml(for: baseSize.value, unit: parsed.unit)
        
        let size = Food.Size()
        size.name = parsed.servingName.capitalized
        size.unit = .mL
        size.amount = baseVolume / parsed.servingValue
        
        food.setAmount(basedOn: baseVolume)
//        food.amount = baseVolume < 100 ? 100 / baseVolume : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .mL, amount: size.amount * parsed.servingValue, baseFoodSize: size)
        )

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithVolume
        }.compactMap { scrapedSize -> Food.Size? in
            let s = Food.Size()
            guard let parsed = ServingType.parseServingWithVolume(scrapedSize.name) else {
                print("Couldn't parse servingWithVolume: \(scrapedSize)")
                return nil
            }
            s.name = parsed.name
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume / size.amount
            s.size = size
            return s
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                s.name = parsed.serving
            } else {
                s.name = scrapedSize.cleanedName
            }
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseVolume
            s.size = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    var foodStartingWithVolumeWithWeight: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0, let parsed = ServingType.parseVolumeWithWeight(baseSize.name), let volumeUnit = parsed.volumeUnit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .mL
        food.servingAmount = baseSize.processedSize.ml(for: baseSize.value, unit: volumeUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        food.densityWeight = baseSize.processedSize.g(for: parsed.weight, unit: parsed.weightUnit)
        food.densityVolume = food.servingAmount
        
        if volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = parsed.volumeString.capitalized
            size.amount = 1.0/baseSize.value
            size.unit = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithVolume
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                guard let parsed = ServingType.parseServingWithVolume(scrapedSize.name) else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = parsed.name
                s.unit = .size
                s.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
                s.size = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .servingWithVolume
            }
            food.sizes.append(
                contentsOf: createSizes(from: sizesToAdd, unit: .mL, amount: baseSize.value * food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    var foodStartingWithWeightWithVolume: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0, let parsed = ServingType.parseWeightWithVolume(baseSize.name), let weightUnit = parsed.weightUnit
        else {
            return nil
        }

        let food = baseFood
        
        food.servingUnit = .g
        food.servingAmount = baseSize.processedSize.g(for: baseSize.value, unit: weightUnit)
        food.setAmount(basedOn: food.servingAmount)
//        food.amount = food.servingAmount < 100 ? 100 / food.servingAmount : 1
        
        /// now get the weight unit
        food.densityWeight = food.servingAmount
        food.densityVolume = baseSize.processedSize.ml(for: parsed.volume, unit: parsed.volumeUnit)
        
        if parsed.volumeUnit == .cup {
            /// add this as a size in case it has a description
            let size = Food.Size()
            size.name = parsed.volumeUnit.description.capitalized
            size.amount = 1.0/parsed.volume
            size.unit = .serving
            food.sizes.append(size)
            
            food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
                scrapedSize.type == .servingWithWeight
            }.compactMap { scrapedSize -> Food.Size? in
                let s = Food.Size()
                guard let parsed = ServingType.parseServingWithWeight(scrapedSize.name) else {
                    print("Couldn't parse servingWithVolume: \(scrapedSize)")
                    return nil
                }
                s.name = parsed.name
                s.unit = .size
                s.amount = baseSize.multiplier * scrapedSize.multiplier * baseSize.value
                s.size = size
                return s
            })
        } else {
            /// add remaining servings or descriptive volumes
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .servingWithWeight
            }
            food.sizes.append(
                contentsOf:
                    createSizes(from: sizesToAdd, unit: .g, amount: food.servingAmount)
            )
        }

        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
    //MARK: - Helpers
    
    func createSizes(from scrapedSizes: [ScrapedSize], unit: SizeUnit, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
        var sizes: [Food.Size] = []
        for scrapedSize in scrapedSizes {
            let size = Food.Size()
            if scrapedSize.type == .servingWithWeight, let parsed = ServingType.parseServingWithWeight(scrapedSize.name) {
                size.name = parsed.name.capitalized
            } else if scrapedSize.type == .servingWithVolume, let parsed = ServingType.parseServingWithVolume(scrapedSize.name) {
                size.name = parsed.name.capitalized
            } else if scrapedSize.type == .servingWithServing, let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                size.name = parsed.serving.capitalized
            } else {
                size.name = scrapedSize.cleanedName.capitalized
            }
            size.unit = unit
            size.amount = amount * scrapedSize.multiplier
            
            if !sizes.contains(size) && size != baseFoodSize {
                sizes.append(size)
            }
        }
        return sizes
    }
}
