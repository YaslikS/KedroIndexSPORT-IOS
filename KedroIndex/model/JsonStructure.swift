import Foundation

struct JsonStructure : Codable{
    var name1: String = "measures1"
    let measures1: [MeasureNew]
    var name2: String = "measures2"
    let measures2: [MeasureNew]
}
