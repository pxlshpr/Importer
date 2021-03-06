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
    case volumeWithWeight
    case weightWithVolume
    case volumeWithServing
    case servingWithServing
    case unsupported

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
    
    static func all(excluding: [ServingType]) -> [ServingType] {
        Array(Set(ServingType.allCases).subtracting(excluding))
    }
}

extension ServingType {    
    static var weightBasedTypes: [ServingType] {
        //TODO: Check that adding .weightWithVolume is valid
        [.weight, .servingWithWeight, .weightWithServing, .weightWithVolume]
    }

    static var volumeBasedTypes: [ServingType] {
        //TODO: Check that adding .volumeWithWeight is valid
        [.volume, .servingWithVolume, .volumeWithServing, .volumeWithWeight]
    }

    var startsWithVolume: Bool {
        [.volume, .volumeWithServing, .volumeWithWeight].contains(self)
    }

    var startsWithWeight: Bool {
        [.weight, .weightWithServing, .weightWithVolume].contains(self)
    }
    var isWeightBased: Bool {
        Self.weightBasedTypes.contains(self)
    }
    
    var isVolumeBased: Bool {
        Self.volumeBasedTypes.contains(self)
    }
}
