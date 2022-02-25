import Foundation

public extension String {
    func extractCapturedGroups(using format: String) -> [String] {

        let range = NSRange(
            startIndex..<endIndex,
            in: self
        )

        // Create A NSRegularExpression
        let capturePattern = format
        let captureRegex = try! NSRegularExpression(
            pattern: capturePattern,
            options: [.caseInsensitive]
        )
        
        // Find the matching capture groups
        let matches = captureRegex.matches(
            in: self,
            options: [],
            range: range
        )

        guard let match = matches.first else {
            return []
        }
        
        var captureGroups: [String] = []

        // For each matched range, extract the capture group
        for rangeIndex in 0..<match.numberOfRanges {
            let matchRange = match.range(at: rangeIndex)
            
            // Ignore matching the entire username string
            if matchRange == range { continue }
            
            // Extract the substring matching the capture group
            if let substringRange = Range(matchRange, in: self) {
                let capture = String(self[substringRange])
                captureGroups.append(capture)
            }
        }

        return captureGroups
    }
    
    func extractFirstCapturedGroup(using format: String) -> String? {
        return extractCapturedGroups(using: format).first
    }
    
    func extractSecondCapturedGroup(using format: String) -> String? {
        let groups = extractCapturedGroups(using: format)
        guard groups.count > 1 else { return nil }
        return groups[1]
    }
}

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
    
    var dateFromTimestamp: Date? {
        guard let timeInterval = TimeInterval(self) else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
}

extension String {
    func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(
                markdown: self,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
        } catch {
            print("Error parsing Markdown for string \(self): \(error)")
            return AttributedString(self)
        }
    }
}

public extension String {
    func matchesRegex(_ regex: String, caseInsensitive: Bool = false) -> Bool {
        let options: String.CompareOptions = caseInsensitive ? [.regularExpression, .caseInsensitive] : [.regularExpression]
        return range(of: regex, options: options, range: nil, locale: nil) != nil
    }
}

extension String {
    var mfpSearchUrlString: String {
        "https://www.myfitnesspal.com/food/search?search=\(self.percentEscaped)"
    }
    
    var dashEscaped: String {
        self.replacingOccurrences(of: " ", with: "-")
    }
    var percentEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
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
        guard let suffix = self.extractFirstCapturedGroup(using: regex) else {
            return false
        }
        return suffix.count > 2
    }
    
    var RxMixedNumber: String { #"([0-9]*) ([0-9]*\/[0-9]*)"# }
    
    var doubleFromMixedNumber: Double? {
        guard
            let wholeNumberString = extractFirstCapturedGroup(using: RxMixedNumber),
            let fractionString = extractSecondCapturedGroup(using: RxMixedNumber),
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
