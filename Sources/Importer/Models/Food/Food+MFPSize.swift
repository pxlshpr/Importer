import Foundation

extension Food {
    func importMFPSizes(from mfpSizes: [MFPFood.Size], ofTypes types: [ServingType], withFirstFoodSize firstFoodSize: Food.Size? = nil) {
        guard let firstSize = mfpSizes.first, mfpSizes.count > 1 else { return }
        let extraSizes = Array(mfpSizes.dropFirst())
        
//        //TODO: Stop Using this
//        let sizesToAdd = extraSizes.filter {
//            $0.type == .serving
//        }
//        sizes.append(
//            contentsOf: MFPFood.createSizes(from: sizesToAdd, unit: .volume, amount: firstFoodSize.amount * firstSize.value, baseFoodSize: firstFoodSize)
//        )
        
        let sizesToAdd: [Food.Size] = extraSizes.filter { types.contains($0.type) }.compactMap {
            switch $0.type {
            case .servingWithWeight:
                return Food.Size(servingWithWeight: $0, firstMFPSize: firstSize)
            case .volumeWithServing:
                return Food.Size(volumeWithServing: $0, mfpSizes: mfpSizes)
            case .servingWithVolume:
                guard let firstFoodSize = firstFoodSize else { return nil }
                return Food.Size(servingWithVolume: $0, firstSize: firstFoodSize, mfpSizes: mfpSizes)
            case .servingWithServing:
                guard let firstFoodSize = firstFoodSize else { return nil }
                return Food.Size(servingWithServing: $0, baseFoodSize: firstFoodSize, mfpSizes: mfpSizes)
            default:
                return nil
            }
        }.removingDuplicates()
        
        sizes.append(contentsOf: sizesToAdd)
    }
    
}
