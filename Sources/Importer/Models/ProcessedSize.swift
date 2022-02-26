import SwiftSugar
import PrepUnits

public struct ProcessedSize {
    public var name: String
    public var type: ServingType
    public var isCorrect: Bool? = nil
    public var correctType: ServingType? = nil
    public var foods: [MyFitnessPalFood] = []
    
    public init(servingSize: MyFitnessPalFood.ScrapedSize) {
        self.name = servingSize.name
        self.type = servingSize.type
    }
    
    func servingSize(for food: MyFitnessPalFood) -> MyFitnessPalFood.ScrapedSize {
        food.scrapedSizes.first(where: {
            $0.name == name
        })!
    }
}

extension ProcessedSize: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(isCorrect)
        hasher.combine(correctType)
    }
    public static func ==(lhs: ProcessedSize, rhs: ProcessedSize) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ProcessedSize {

    public var measurementString: String? {
        if let g = g {
            if type == .volumeWithWeight {
                guard let parsed = ServingType.parseVolumeWithWeight(name),
                      let volume = parsed.volume,
                      let volumeString = volume.string
                else {
                    print("⚠️ Got: 'nil' for: \(name)")
                    return nil
                }
                //TODO: remove this conditional and make volumeUnit (and weightUnit in the mirrored one non-optional), since it can't fail
                if let volumeUnit = parsed.volume?.unit {
                    return "\(ml(for: 1.0, unit: volumeUnit)) mL = \(g.cleanWithoutRounding) g"
                } else {
                    return "\(volumeString) = \(g.cleanWithoutRounding) g"
                }
            } else {
                return "\(g.cleanWithoutRounding) g"
            }
        } else if let ml = ml {
            if type == .weightWithVolume {
                guard let parsed = ServingType.parseWeightWithVolume(name),
                      let weight = parsed.weight,
                      let weightString = weight.string
                else {
                    print("⚠️ Got: 'nil' for: \(name)")
                    return nil
                }
                if let weightUnit = weight.unit {
                    return "\(g(for: 1.0, unit: weightUnit)) g = \(ml.cleanWithoutRounding) mL"
                } else {
                    return "\(weightString) g = \(ml.cleanWithoutRounding) mL"
                }
            } else {
                return "\(ml.cleanWithoutRounding) mL"
            }
        } else if let serving = serving {
            return serving
        }
        return nil
    }
    
    func g(for value: Double, unit: ImporterWeightUnit) -> Double {
        let multiplier: Double
        switch unit {
        case .g:
            multiplier = 1
        case .kg:
            multiplier = 1000
        case .mg:
            multiplier = 0.001
        case .oz:
            multiplier = 28.34952
        case .lb:
            multiplier = 453.59237
        }
        return value * multiplier
    }

    func ml(for value: Double, unit: VolumeUnit) -> Double {
        let multiplier: Double
        switch unit {
        case .mL:
            multiplier = 1
//        case .l:
//            multiplier = 1000
        case .cup:
            multiplier = 236.588
        case .teaspoon:
            multiplier = 4.92892
        case .tablespoon:
            multiplier = 14.7868
        case .fluidOunce:
            multiplier = 29.5735
        case .gallon:
            multiplier = 3785.411784
        case .quart:
            multiplier = 946
        case .pint:
            multiplier = 480
        }
        return value * multiplier
    }

    var g: Double? {
        switch type {
        case .weight:
            if let unit = ServingType.weightUnit(of: name).weight?.unit {
                return g(for: 1.0, unit: unit)
            }
            return nil
        case .servingWithWeight:
            guard let parsed = ServingType.parseServingWithWeight(name),
                  let servingAmount = parsed.serving?.amount,
                  let weightUnit = parsed.weight?.unit
            else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return g(for: servingAmount, unit: weightUnit)
        case .volumeWithWeight:
            guard let parsed = ServingType.parseVolumeWithWeight(name),
                  let weightAmount = parsed.weight?.amount,
                  let weightUnit = parsed.weight?.unit
            else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return g(for: weightAmount, unit: weightUnit)
        default:
            return nil
        }
    }
    
    var serving: String? {
        switch type {
        case .weightWithServing:
            guard let parsed = ServingType.parseWeightWithServing(name),
                  let serving = parsed.serving,
                  let servingAmount = serving.amount
            else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return "\(servingAmount.cleanWithoutRounding) \(serving.name)"
        case .volumeWithServing:
            guard let parsed = ServingType.parseVolumeWithServing(name) else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return "\(parsed.servingValue.cleanWithoutRounding) \(parsed.servingName)"
        case .servingWithServing:
            guard let parsed = ServingType.parseServingWithServing(name) else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return "\(parsed.constituentAmount.cleanWithoutRounding) \(parsed.constituentName)"
        default:
            return nil
        }
    }
    
    var ml: Double? {
        switch type {
        case .volume:
            if let unit = ServingType.volumeUnit(of: name) {
                return ml(for: 1.0, unit: unit)
            }
            return nil
        case .servingWithVolume:
            guard let parsed = ServingType.parseServingWithVolume(name),
                  let servingAmount = parsed.serving?.amount,
                  let volumeUnit = parsed.volume?.unit
            else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return ml(for: servingAmount, unit: volumeUnit)
        case .weightWithVolume:
            guard let parsed = ServingType.parseWeightWithVolume(name),
                  let volumeAmount = parsed.volume?.amount,
                  let volumeUnit = parsed.volume?.unit
            else {
                print("⚠️ Got: 'nil' for: \(name)")
                return nil
            }
            return ml(for: volumeAmount, unit: volumeUnit)

        default:
            return nil
        }
    }
}
