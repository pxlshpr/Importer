import Foundation

//4D3536AB
public struct Density {
    let volume: Double
    let weight: Double
    
    init?(volume: Double, weight: Double) {
        guard volume > 0 && weight > 0 else {
            return nil
        }
        self.volume = volume
        self.weight = weight
    }
}

extension Density: Equatable {
    public static func ==(lhs: Density, rhs: Density) -> Bool {
        lhs.volume / lhs.weight == rhs.volume / rhs.weight
    }
}
