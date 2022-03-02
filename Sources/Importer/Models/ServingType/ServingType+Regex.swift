import Foundation

extension ServingType {
    public var regex: String {
        switch self {
        case .weight:
            return Rx.weight
        case .volume:
            return Rx.volume
        case .serving:
            return Rx.serving
        case .servingWithWeight:
            return Rx.servingWithWeight
        case .servingWithVolume:
            return Rx.servingWithVolume
        case .weightWithServing:
            return Rx.weightWithServing
        case .volumeWithServing:
            return Rx.volumeWithServing
        case .servingWithServing:
            return Rx.servingWithServing
        case .unsupported:
            return ""
        case .volumeWithWeight:
            return Rx.volumeWithWeight
        case .weightWithVolume:
            return Rx.weightWithVolume
        }
    }
}

public extension ServingType {
    struct Rx {
    }
}

public extension ServingType.Rx {
    //MARK: - Components
    
    static let pluralSuffix =
    #"(?:\'s|\(s\)|s)?"#

    static let notNumeral =
    #"[^0-9]"#
    
    static let notNumber =
    #"[^0-9.,\/]"#
    
    static let number =
    #"[0-9,.\/]"#

    /// includes fractions like 1 1/10
    /// raw number following by an optional—space and another raw number—one or more times
    static let numberOrFraction =
    #"\#(number)+( \#(number)+)?"#

    static let optionalSpace =
    #"[ ]*"#
    
    static let optionalPeriod =
    #"\.?"#

    static let separator =
    #"[ ]*(-|–|—|:|\()[ ]*"#
    
    //MARK: Units
    static let weights =
    #"(g raw weight|wt\. oz|ounce|pound|gramm|gram|oz\.|kg|mg|gr|gm|g|oz|lb)"#
    
    static let unitDescription =
    #",? [A-Za-z \(\)]*"#
    
    static let volumes =
    #"(fluid ounce|tablespoon|milliliter|millilitre|mililiter|mililitre|teaspoon|gallon|fl\. oz\.?|oz\. fl\.|oz fl|fl oz|litre|quart|pint|tbsp|gal|cup\#(pluralSuffix)\#(unitDescription)|tbs\.|tbs|cup|tsp|ltr|ml|pt|qt|l|c|c\#(pluralSuffix)\#(unitDescription))"#
    
    static let volumeUnits =
    #"\#(volumes)\#(pluralSuffix)"#

    static let weightUnits =
    #"\#(weights)\#(pluralSuffix)"#

    //MARK: - Helpers
    static let withServingSuffix =
    #"\#(pluralSuffix)[ ]*\(?\#(notNumber)*\#(number)+[ ]+[A-Za-z,]+\)?"#
   
    /**
     Either ends with:
     - end of the string ($)
     - a bracket close `)` followed by $
     - a space that is followed by
        - **not** the sequence:
            - any number of characters
            - any *weight unit*
            - a space or $
        - any number of characters
     */
    static let servingWithVolumeSuffix =
    #"(\)|$| (?!.*\#(weightUnits)( |$)).*)"#

    static let servingWithWeightSuffix =
    #"(\)|$| (?!.*\#(volumeUnits)( |$)).*)"#

    static let spaceFollowedByAnythingButWeightUnitTillEndOfLine =
    #" .*(?!\#(weightUnits)($| .*$))"#
    /// space or
    /// or s followed by
    ///     or space
    ///     or EOL
    ///     (
    /// or EOL
    /// or (

    static let startsWithWeight =
    #"^\#(weightUnits) .*$"#

    static let startsWithVolume =
    #"^\#(volumeUnits) .*$"#

    /// Only allows numbers such as 5", 2', 3.3"
    static let onlyNumbersFollowedBySize =
    #"\#(notNumber)*[0-9,.\/\- ]*(?=("|'))\#(notNumber)*"#
    
    static let servingPrefix =
    #"\#(notNumeral)+[ ].*\#(numberOrFraction)\#(optionalSpace)"#
    
    static let weightEquatingWeight =
    #"^\#(weightUnits)\#(separator)\#(numberOrFraction)\#(optionalSpace)\#(weightUnits)\)?$"#

    static let volumeEquatingVolume =
    #"^\#(volumeUnits)\#(separator)\#(numberOrFraction)\#(optionalSpace)\#(volumeUnits)\)?$"#

    static let endsWithWeight =
    #"^.*\#(weightUnits)(\)$|$)"#

    static let endsWithVolume =
    #"^.*\#(volumeUnits)(\)$|$)"#

    static let startsAndEndsWithWeight =
    #"^(?=\#(startsWithWeight))(?=\#(endsWithWeight)).*$"#

    static let startsAndEndsWithVolume =
    #"^(?=\#(startsWithWeight))(?=\#(endsWithWeight)).*$"#

    static let rawServingWithWeight =
    #"^\#(servingPrefix)\#(weightUnits)\#(servingWithWeightSuffix)"#

    static let rawServingWithVolume =
    #"^\#(servingPrefix)\#(volumeUnits)\#(servingWithVolumeSuffix)"#

    static let rawWeightWithServing =
    #"^\#(weightUnits)([ ]*\/[ ]*\#(number)+\#(weightUnits))*\#(withServingSuffix)$"#

    static let rawVolumeWithServing =
    #"^\#(volumeUnits)([ ]*\/[ ]*\#(number)+\#(volumeUnits))*\#(withServingSuffix)$"#

    //MARK: - Identifiers

    static let weight =
    #"^\#(weightUnits)$|\#(weightEquatingWeight)|\#(startsAndEndsWithWeight)"#

    static let volume =
    #"^\#(volumeUnits)$|\#(volumeEquatingVolume)|\#(startsAndEndsWithVolume)"#

    static let rawServing =
    #"^\#(onlyNumbersFollowedBySize)$|^\#(notNumeral)*$"#
    
    static let serving =
    #"(?=\#(rawServing))(?!\#(servingWithWeight))(?!\#(servingWithVolume))(?!\#(startsWithWeight))(?!\#(startsWithVolume)).*$"#
    
    static let servingWithWeight =
//        #"^(?=\#(rawServingWithWeight))(?!\#(startsWithWeight)).*$"#
    #"^(?=\#(rawServingWithWeight))(?!\#(startsWithWeight))(?!\#(volumeWithWeight)).*$"#

    static let servingWithVolume =
    #"^(?=\#(rawServingWithVolume))(?!\#(startsWithVolume))(?!\#(weightWithVolume))(?!\#(servingWithWithInName)).*$"#

    static let weightWithServingWithSizeNumber =
    #"^\#(weightUnits) ?[^0-9.,\/]*[0-9,.\/\- ]*(?=(\"|\'))[^0-9.,\/]*$"#

    static let weightWithServing =
    #"^(?=\#(rawWeightWithServing)|\#(weightWithServingWithSizeNumber))(?!\#(endsWithWeight))(?!\#(endsWithVolume)).*$"#

    static let volumeWithServing =
    #"^(?=\#(rawVolumeWithServing))(?!\#(endsWithVolume))(?!\#(endsWithWeight)).*$"#

    static let servingWithServing =
    #"^(?=^\#(servingPrefix).*$)(?!\#(servingWithWeight))(?!\#(servingWithVolume))(?!\#(weightWithServing))(?!\#(volumeWithWeight))(?!\#(weightWithVolume))(?!\#(servingWithWithInName)).*$"#
    
    static let volumeWithWeight =
    #"^\#(volumeUnits)( |\(|-)\#(notNumber)*\#(number)+[ ]*\#(weightUnits)\#(optionalPeriod)\#(notNumber)*$"#

    /// matches stuff like `g with 200ml milk` that should be a `serving` but could be mistaken for a `weight w/ volume` otherwise
    static let servingWithWithInName =
    #"^.*(\#(weightUnits)|\#(volumeUnits))( |\()(with) [0-9]+(\#(weightUnits)|\#(volumeUnits)).*$"#
    
    static let rawWeightWithVolume =
    #"^\#(weightUnits)( |\(|-)\#(notNumber)*\#(number)+[ ]*\#(volumeUnits)\#(optionalPeriod)\#(notNumber)*$"#

    static let weightWithVolume =
    #"^(?=\#(rawWeightWithVolume))(?!\#(servingWithWithInName)).*$"#

    //MARK: - Extractors
    static let doubleBracketedServing =
    #"container.*\#(number)+\#(notNumber)+(( |\()\#(number)+\#(notNumber)+( ea\.)?)\)$"#
    
    //MARK: - Unsorted
    static let servingWithWeightLastValue =
    #"^(.*)(?:\(| )(\#(numberOrFraction))\#(weightUnits)+\)?$"#
    
    static let servingWithWeightFirstValue =
    #"^([^0-9.,\/]+)(\#(numberOrFraction))[ ]*\#(weightUnits).*$"#
    
    static let servingWithWeightExtractor =
    #"\#(servingWithWeightFirstValue)|\#(servingWithWeightLastValue)"#
    
    static let weightWithServingExtractor =
    #"^\#(weightUnits)(\(| |\/)?.*( |\()([0-9.,\/]+) ([^\)]*)\)?$"#

    static let weightWithServingHavingSizeNumberExtractor =
    #"^\#(weightUnits)(\(| |\/)?(.*)$"#

    static let volumeWithServingHavingSizeNumberExtractor =
    #"^\#(volumeUnits)(\(| |\/)?(.*)$"#

    static let servingWithVolumeLastValue =
    #"^(.*)(?:\(| )(\#(numberOrFraction))\#(volumeUnits)+\)?$"#
    
    static let servingWithVolumeFirstValue =
    #"^([^0-9.,\/]+)(\#(numberOrFraction))[ ]*\#(volumeUnits).*$"#
    
    static let servingWithVolumeExtractor =
    #"\#(servingWithVolumeFirstValue)|\#(servingWithVolumeLastValue)"#
    
    static let volumeWithServingExtractor =
    #"^\#(volumeUnits)(\(| |\/)?.*( |\()([0-9.,\/]+) ([^\)]*)\)?$"#

    static let volumeWithDescriptionExtractor =
    #"^\#(volumeUnits)(\(| |\/)?.*( |\()?([0-9.,\/]?) ([^\)]*)\)?$"#

    static let servingWithServingExtractor =
    #"^(.*) \(?([0-9.,\/]+) ([^0-9.,\/]+)[ ]?(ea\.)? ?\)?$"#
    
    static let volumeWithWeightExtractor =
    #"\#(volumeUnits)[^0-9.,\/]+([0-9.,\/]+)[ ]*\#(weightUnits) ?\.?\)? ?(.*)$"#
    
    static let weightWithVolumeExtractor =
    #"\#(weightUnits)[^0-9.,\/]+([0-9.,\/]+)[ ]*\#(volumeUnits) ?\.?\)? ?(.*)$"#
}
