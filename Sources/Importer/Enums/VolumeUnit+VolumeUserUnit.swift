import PrepUnits

extension VolumeUnit {
    
    var volumeUserUnit: VolumeUserUnit? {
        switch self {
        case .mL:
            return VolumeMilliliterUserUnit.ml
        case .liter:
            return VolumeLiterUserUnit.liter
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
