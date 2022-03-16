import Foundation

extension Food {
    func importMFPSizes(from mfpSizes: [MFPFood.Size], ofTypes types: [ServingType], withFirstFoodSize firstFoodSize: Food.Size? = nil) {
        
        let sizesToAdd = mfpSizes
            .filter { types.contains($0.type) }
            .compactMap { Food.Size(mfpSize: $0, mfpSizes: mfpSizes) }
            .removingDuplicates()
            .dropFirst()
        
        sizes.append(contentsOf: sizesToAdd)
    }
    
}
