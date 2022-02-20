import Foundation

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
