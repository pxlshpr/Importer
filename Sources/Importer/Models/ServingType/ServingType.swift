import Foundation

public enum ServingType: Int, CaseIterable, Identifiable {
    
    public var id: String {
        return "\(rawValue)"
    }
    /// **Important** : Make sure new cases are added at bottom to ensure saved `Int` values correctly identify previous cases
    case weight
    case volume
    case serving
    case servingWithWeight
    case servingWithVolume
    case weightWithServing
    case volumeWithServing
    case servingWithServing
    case unsupported
    case volumeWithWeight
    case weightWithVolume

    public var description: String {
        switch self {
        case .weight:
            return "Weight"
        case .volume:
            return "Volume"
        case .serving:
            return "Serving"
        case .servingWithWeight:
            return "Serving with Weight"
        case .servingWithVolume:
            return "Serving with Volume"
        case .weightWithServing:
            return "Weight with Serving"
        case .volumeWithServing:
            return "Volume with Serving"
        case .servingWithServing:
            return "Serving with Serving"
        case .unsupported:
            return "Unsupported"
        case .volumeWithWeight:
            return "Volume with Weight (Density)"
        case .weightWithVolume:
            return "Weight with Volume (Density)"
        }
    }
}

extension ServingType {    
    static var weightBasedTypes: [ServingType] {
        [.weight, .servingWithWeight, .weightWithServing]
    }

    static var volumeBasedTypes: [ServingType] {
        [.volume, .servingWithVolume, .volumeWithServing]
    }
    
    var isWeightBased: Bool {
        Self.weightBasedTypes.contains(self)
    }
    
    var isVolumeBased: Bool {
        Self.volumeBasedTypes.contains(self)
    }
}
