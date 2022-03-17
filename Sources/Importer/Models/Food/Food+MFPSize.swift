import Foundation

extension Food {
    func importMFPSizes(from mfpSizes: [MFPFood.Size], ofTypes types: [ServingType]) {
        
        guard let firstSize = mfpSizes.first,
              let firstFoodSize = Food.Size(mfpSize: firstSize, mfpSizes: mfpSizes)
        else {
            return
        }
        
        var sizesToAdd = mfpSizes
            .dropFirst()
            .filter { types.contains($0.type) }
            .compactMap { Food.Size(mfpSize: $0, mfpSizes: mfpSizes) }
            .removingDuplicates()
        sizesToAdd.removeAll(where: { $0 == firstFoodSize })
        
        sizes.append(contentsOf: sizesToAdd)
    }
    
}
