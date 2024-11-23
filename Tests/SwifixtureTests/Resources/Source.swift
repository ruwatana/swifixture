import Foundation

/// @fixturable(override: customEnumWithOverride = .a, customEnumWithOverride2 = .b)
struct VariousPropertiesStruct {
    let any: Any
    let anyObject: AnyObject
    let bool: Bool
    let character: Character
    let data: Data
    let date: Date
    let double: Double
    let float: Float
    let int: Int
    let int8: Int8
    let int16: Int16
    let int32: Int32
    let int64: Int64
    let set: Set<String>
    let string: String
    let uint: UInt
    let uint8: UInt8
    let uint16: UInt16
    let uint32: UInt32
    let uint64: UInt64
    let url: URL
    let uuid: UUID
    
    let optional: String?
    let implicitlyUnwrappedOptional: String!
    
    let array: Array<String>
    let arrayLiteral: [String]
    let arrayOptional: [String]?
    
    let dictionary: Dictionary<String, Any>
    let dictionaryLiteral: [String: Any]
    let dictionaryOptional: [String: Any]?
    
    let tuple: (String, Int)
    let tupleOptional: (String, Int)?
    let tupleWithArgumentNames: (name: String, age: Int)
    let tupleWithArgumentNamesOptional: (name: String, age: Int)?
    
    let closure: () -> Void
    let closureOptional: (() -> Void)?
    let closureWithArguments: (Int) -> String
    let closureWithArgumentsOptional: ((Int) -> String)?
    let attributeClosure: @autoclosure () -> Void
    let escapingClosure: @escaping () -> Void
    let escapingClosureOptional: @escaping (() -> Void)?
    
    let customEnumWithOverride: CustomEnum
    let customEnumWithOverride2: CustomEnum
    let otherFixturableStruct: CustomStruct
}

enum CustomEnum {
    case a
    case b
    case c
}

/// @fixturable
struct CustomStruct {}
