extension Food.Size {
    
//    convenience init?(servingWithWeight mfpSize: MFPFood.Size, firstMFPSize: MFPFood.Size) {
//        guard let servingName = mfpSize.parsed?.serving?.name,
//              let weightAmount = mfpSize.parsed?.weight?.amount
//        else {
//            return nil
//        }
//        
//        self.init()
//        name = servingName
//        
//        if firstMFPSize.type.startsWithWeight {
//            /// for sizes like "Container (2250g) = 72x"—mark it as being 72 servings as opposed to 2.5 kg (as the weight gets inferred in the description either way)
//            amount = mfpSize.multiplier
//            amountUnit = .serving
//        } else {
//            amount = weightAmount
//            amountUnit = .weight
//            amountWeightUnit = mfpSize.weightUnit
//        }
//    }
}
