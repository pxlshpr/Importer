import Foundation

let RxFileWithTimestamp = #"([0-9]+)_(.*).txt"#
let RxContainsTwoNumbers =  #"[^0-9,.\/]+[0-9,.\/]+[^0-9,.\/]+( |\()[0-9,.\/]+[^0-9,.\/]+ea.\)$"#

extension String {
    var cleaned: String {
        var cleaned = self
        if cleaned.hasPrefix("-") {
            cleaned.removeFirst(1)
        }
        if cleaned.hasSuffix("-") {
            cleaned.removeLast(1)
        }
        if cleaned.hasSuffix(" (") {
            cleaned.removeLast(2)
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespaces)
        return cleaned
    }
}

extension String {
    var mfpSearchUrlString: String {
        "https://www.myfitnesspal.com/food/search?search=\(self.percentEscaped)"
    }
}

extension String {
    
    var doubleFromExtractedNumber: Double? {
        
        guard !self.containsMixedNumber else {
            return doubleFromMixedNumber
        }
        
        guard !self.contains(",") else {
            if amountCommaIsThousandSeparator {
                /// handles 1,000 etc.
                return Double(replacingOccurrences(of: ",", with: ""))
            } else {
                /// e.g. 62,5 for 62.5 in some countries
                return Double(replacingOccurrences(of: ",", with: "."))
            }
        }
        
        guard !self.contains("/") else {
            return fraction
        }
        
        return Double(self)
    }
    
    var amountCommaIsThousandSeparator: Bool {
        let regex = ",([0-9]*)"
        guard let suffix = self.firstCapturedGroup(using: regex) else {
            return false
        }
        return suffix.count > 2
    }
    
    var RxMixedNumber: String { #"([0-9]*) ([0-9]*\/[0-9]*)"# }
    
    var doubleFromMixedNumber: Double? {
        guard
            let wholeNumberString = firstCapturedGroup(using: RxMixedNumber),
            let fractionString = secondCapturedGroup(using: RxMixedNumber),
            let wholeNumber = Double(wholeNumberString),
            let fraction = fractionString.fraction
        else {
            return nil
        }
        return wholeNumber + fraction
    }
    
    var containsMixedNumber: Bool {
        matchesRegex(RxMixedNumber)
    }
    
    var fraction: Double? {
        let components = components(separatedBy: "/")
        guard let numerator = Double(components[0]),
                let denominator = Double(components[1])
        else {
            return nil
        }
        return numerator/denominator
    }
}
