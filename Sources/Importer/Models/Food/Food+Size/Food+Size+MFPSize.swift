import Foundation
import PrepUnits
import UIKit

extension Food.Size {
//TODO: Remove
//    convenience init(mfpSize: MFPFood.Size, unit: UnitType, amount: Double) {
//        self.init()
//
//        self.amountUnit = unit
//        self.amount = amount * mfpSize.multiplier
//
//        do {
//            switch mfpSize.type {
//            case .servingWithWeight:
//                try fillInServingWithWeight(named: mfpSize.name)
//            case .servingWithServing:
//                try fillInServingWithServing(named: mfpSize.name)
//            case .servingWithVolume:
//                try fillInServingWithVolume(mfpSize, unit: unit, amount: amount)
//            case .volumeWithWeight:
//                try fillInVolumeWithWeight(mfpSize, unit: unit, amount: amount)
//            default:
//                name = mfpSize.cleanedName
//            }
//        } catch {
//            name = mfpSize.cleanedName
//        }
//
//        name = name.capitalizingFirstLetter()
//    }
//
//    func fillInServingWithWeight(named name: String) throws {
//        guard let servingName = name.parsedServingWithWeight.serving?.name else {
//            throw ParseError.unableToParse
//        }
//        self.name = servingName
//    }
//
//    func fillInServingWithServing(named name: String) throws {
//        guard let servingName = name.parsedServingWithServing.serving?.name else {
//            throw ParseError.unableToParse
//        }
//        self.name = servingName
//    }
//
//    func fillInVolumeWithWeight(_ mfpSize: MFPFood.Size, unit: UnitType, amount: Double) throws {
//        let parsed = mfpSize.name.parsedVolumeWithWeight
//        guard let volumeUnit = parsed.volume?.unit else {
//            throw ParseError.unableToParse
//        }
//
//        self.name = mfpSize.cleanedName
//        self.amountUnit = .volume
//        self.amountVolumeUnit = volumeUnit
//        self.amount = mfpSize.trueValue
//    }
//
//    func fillInServingWithVolume(_ mfpSize: MFPFood.Size, unit: UnitType, amount: Double) throws {
//        let parsed = mfpSize.name.parsedServingWithVolume
//        guard let serving = parsed.serving,
//              let servingAmount = serving.amount,
//              let volumeUnit = parsed.volume?.unit
//        else {
//            throw ParseError.unableToParse
//        }
//
//        self.name = serving.name
//        self.amountUnit = .volume
//        self.amountVolumeUnit = volumeUnit
//        self.amount = servingAmount
//    }
    
    enum ParseError: Error {
        case unableToParse
    }
}
