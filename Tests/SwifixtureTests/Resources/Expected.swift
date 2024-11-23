///
///  @Generated by Swifixture
///

import Foundation


extension CustomStruct {
    static func fixture() -> Self {
        .init()
    }
}


extension VariousPropertiesStruct {
    static func fixture(
        any: Any = 0,
        anyObject: AnyObject = 0 as AnyObject,
        bool: Bool = false,
        character: Character = "c",
        data: Data = .init(),
        date: Date = .init(),
        double: Double = 0.0,
        float: Float = 0.0,
        int: Int = 0,
        int8: Int8 = 0,
        int16: Int16 = 0,
        int32: Int32 = 0,
        int64: Int64 = 0,
        set: Set<String> = [],
        string: String = "string",
        uint: UInt = 0,
        uint8: UInt8 = 0,
        uint16: UInt16 = 0,
        uint32: UInt32 = 0,
        uint64: UInt64 = 0,
        url: URL = .init(string: "http://localhost")!,
        uuid: UUID = .init(),
        optional: String? = nil,
        implicitlyUnwrappedOptional: String! = "implicitlyUnwrappedOptional",
        array: Array<String> = .fixture(),
        arrayLiteral: [String] = [],
        arrayOptional: [String]? = nil,
        dictionary: Dictionary<String, Any> = .fixture(),
        dictionaryLiteral: [String: Any] = [:],
        dictionaryOptional: [String: Any]? = nil,
        tuple: (String, Int) = ("0", 0),
        tupleOptional: (String, Int)? = nil,
        tupleWithArgumentNames: (name: String, age: Int) = (name: "name", age: 0),
        tupleWithArgumentNamesOptional: (name: String, age: Int)? = nil,
        closure: @escaping () -> Void = { },
        closureOptional: (() -> Void)? = nil,
        closureWithArguments: @escaping (Int) -> String = { _ in "" },
        closureWithArgumentsOptional: ((Int) -> String)? = nil,
        attributeClosure: @autoclosure @escaping () -> Void = { },
        escapingClosure: @escaping @escaping () -> Void = { },
        escapingClosureOptional: @escaping (() -> Void)? = nil,
        customEnumWithOverride: CustomEnum = .a,
        customEnumWithOverride2: CustomEnum = .b,
        otherFixturableStruct: CustomStruct = .fixture()
    ) -> Self {
        .init(
            any: any,
            anyObject: anyObject,
            bool: bool,
            character: character,
            data: data,
            date: date,
            double: double,
            float: float,
            int: int,
            int8: int8,
            int16: int16,
            int32: int32,
            int64: int64,
            set: set,
            string: string,
            uint: uint,
            uint8: uint8,
            uint16: uint16,
            uint32: uint32,
            uint64: uint64,
            url: url,
            uuid: uuid,
            optional: optional,
            implicitlyUnwrappedOptional: implicitlyUnwrappedOptional,
            array: array,
            arrayLiteral: arrayLiteral,
            arrayOptional: arrayOptional,
            dictionary: dictionary,
            dictionaryLiteral: dictionaryLiteral,
            dictionaryOptional: dictionaryOptional,
            tuple: tuple,
            tupleOptional: tupleOptional,
            tupleWithArgumentNames: tupleWithArgumentNames,
            tupleWithArgumentNamesOptional: tupleWithArgumentNamesOptional,
            closure: closure,
            closureOptional: closureOptional,
            closureWithArguments: closureWithArguments,
            closureWithArgumentsOptional: closureWithArgumentsOptional,
            attributeClosure: attributeClosure,
            escapingClosure: escapingClosure,
            escapingClosureOptional: escapingClosureOptional,
            customEnumWithOverride: customEnumWithOverride,
            customEnumWithOverride2: customEnumWithOverride2,
            otherFixturableStruct: otherFixturableStruct
        )
    }
}
