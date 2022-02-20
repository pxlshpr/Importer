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

    mutating func appendSize(processedSize: ProcessedSize) {
        guard !processedSizes.contains(processedSize) else {
            return
        }
        processedSizes.append(processedSize)
    }
}
