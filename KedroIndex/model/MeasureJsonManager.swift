import Foundation

// MARK: структура JSON
/*

*/

// MARK: парсинг json
func parcingJson(json: String) -> JsonStructure? {
    NSLog("parcingJson: entrance")
    guard let jsonData = json.data(using: .utf8) else { return nil }
    let jsonStructure: JsonStructure = try! JSONDecoder().decode(JsonStructure.self, from: jsonData)

    NSLog("parcingJson: jsonMessage.measures1[2].KerdoIndex = " + jsonStructure.measures1[0].KerdoIndex)
    NSLog("parcingJson: jsonMessage.measures2[1].KerdoIndex = " + jsonStructure.measures2[0].KerdoIndex)
    
    return jsonStructure
}

// MARK: создание json
func createJson(kerdo1Mas: [MeasureNew], kerdo2Mas: [MeasureNew]) -> String{
    NSLog("createJson: entrance")
    
    let jsonMessageConteiner = JsonStructure(
        name1: "measures1",
        measures1: kerdo1Mas,
        name2: "measures2",
        measures2: kerdo2Mas
    )
    
    let encoder = JSONEncoder()
    var jsonString = ""
    do{
        let jsonData = try encoder.encode(jsonMessageConteiner)
        jsonString = String(data: jsonData, encoding: .utf8) ?? "error create JSON-string"
        
        NSLog("createJson: do: jsonString = {{{\n" + jsonString + "\n}}}")
    } catch _ as NSError {
        NSLog("createJson: catch: jsonString = {{{\n" + jsonString + "\n}}}")
    }

    NSLog("createJson: exit")
    return jsonString
}
