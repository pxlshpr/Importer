import Foundation

public struct MyFitnessPalFood: Identifiable {
    public let id: String
    public let name: String?
    public let brand: String?
    public let energy: Double?
    public let carb: Double?
    public let fat: Double?
    public let protein: Double?
    public let scrapedSizes: [ScrapedSize]
    public let urlSlug: String
    public let createdAt: Date
    public var processedSizes: [ProcessedSize] = []

    public mutating func appendSize(processedSize: ProcessedSize) {
        guard !processedSizes.contains(processedSize) else {
            return
        }
        processedSizes.append(processedSize)
    }
}

extension MyFitnessPalFood: Equatable {
    public static func ==(lhs: MyFitnessPalFood, rhs: MyFitnessPalFood) -> Bool {
        lhs.id == rhs.id
    }
}

extension MyFitnessPalFood.ScrapedSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(multiplier)
        hasher.combine(index)
    }
}
extension MyFitnessPalFood: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(brand)
        hasher.combine(energy)
        hasher.combine(carb)
        hasher.combine(fat)
        hasher.combine(protein)
        hasher.combine(scrapedSizes)
        hasher.combine(processedSizes)
    }
}

//MARK: - CustomStringConvertible

extension MyFitnessPalFood: CustomStringConvertible {

    public var description: String {
        var string = "" +
        stringDescription(label: "Food", string: name) +
        stringDescription(label: "Brand", string: brand) +
        valueDescription(label: "Energy", value: energy, unit: "kcal") +
        valueDescription(label: "Carb", value: carb) +
        valueDescription(label: "Fat", value: fat) +
        valueDescription(label: "Protein", value: protein) +
        "**Servings**:\n\n"
        for size in scrapedSizes {
            string += size.description
        }
        return string
    }
    
    var line: String {
        "------------------------------------------------\n"
    }
}

func tabsString(count: Int) -> String {
    var string = ""
    for _ in 0..<count {
        string += "\t"
    }
    return string
}
func valueDescription(label: String, value: Double?, unit: String = "g", tabs: Int = 0) -> String {
    let tabs = tabsString(count: tabs)
    if let value = value {
        return "\(tabs)**\(label)**: \(value) \(unit)\n"
    } else {
        return "\(tabs)**\(label)**: (nil)\n"
    }
}

func integerDescription(label: String, integer: Int?, unit: String = "g", tabs: Int = 0) -> String {
    let tabs = tabsString(count: tabs)
    if let integer = integer {
        return "\(tabs)**\(label)**: \(integer) \(unit)\n"
    } else {
        return "\(tabs)**\(label)**: (nil)\n"
    }
}

func stringDescription(label: String, string: String?, tabs: Int = 0) -> String {
    let tabs = tabsString(count: tabs)
    return "\(tabs)**\(label)**: \(string ?? "(nil)")\n"
}

