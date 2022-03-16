import Foundation

extension Food {
    func importMFPSizes(from mfpSizes: [MFPFood.Size], ofTypes types: [ServingType]) {
        
        let sizesToAdd = mfpSizes
            .dropFirst()
            .filter { types.contains($0.type) }
            .compactMap { Food.Size(mfpSize: $0, mfpSizes: mfpSizes) }
            .removingDuplicates()
        
        sizes.append(contentsOf: sizesToAdd)
    }
    
}
