import Foundation

// MARK: структура JSON
/*
{
    "emailAddress":"?????????????????????@gmail.com",
    "yourImageURL":"https://lh3.googleusercontent.com/a/?????????????????????????????????????????????????=s320",
    "measures2":[
        {"ki":10,"pulse":80,"dad":50,"date":"1234"},
        {"ki":20,"pulse":90,"dad":60,"date":"1234"},
        {"ki":30,"pulse":100,"dad":70,"date":"1234"}
    ],
    "name":"YaslikS",
    "measures1":[
        {"ki":10,"pulse":80,"dad":50,"date":"1234"},
        {"ki":20,"pulse":90,"dad":60,"date":"1234"},
        {"ki":30,"pulse":100,"dad":70,"date":"1234"}
    ]
}
*/

// MARK: создание JSON-файла
func createJSONforMessage(_ dataForChartsMeasure: NSArray, _ dataForChartsMeasure2: NSArray) -> String{
    NSLog("collectMessage: entrance")
    let storageYourEmailData = StorageYourEmailData()
    let emailAddress = storageYourEmailData.getYourEmailAddress()
    let name = storageYourEmailData.getYourName()
    let yourImageURL = storageYourEmailData.getYourImageURL()
    
    var measures1ForJSON: [JsonMeasures] = []
    var measures2ForJSON: [JsonMeasures] = []
    for index in 0..<dataForChartsMeasure.count {
        let measure1FromDB = dataForChartsMeasure[index] as! Measure
        let measure2FromDB = dataForChartsMeasure2[index] as! Measure2
        
        let m1ForJSON = JsonMeasures(ki: measure1FromDB.kerdoIndex, dad: measure1FromDB.dad, pulse: measure1FromDB.pulse, date: measure1FromDB.date ?? "")
        let m2ForJSON = JsonMeasures(ki: measure2FromDB.kerdoIndex, dad: measure2FromDB.dad, pulse: measure2FromDB.pulse, date: measure2FromDB.date ?? "")
        
        measures1ForJSON.append(m1ForJSON)
        measures2ForJSON.append(m2ForJSON)
    }
    
    let jsonMessageConteiner = JsonMessage(
        emailAddress: emailAddress,
        name: name,
        yourImageURL: yourImageURL,
        measures1: measures1ForJSON,
        measures2: measures2ForJSON
    )
    
    let encoder = JSONEncoder()
    var jsonString = ""
    do{
        let jsonData = try encoder.encode(jsonMessageConteiner)
        jsonString = String(data: jsonData, encoding: .utf8) ?? "error create JSON-string"
        
        print(jsonString)
    } catch _ as NSError {
        NSLog("createJSONforMessage: catch: jsonString = {{{\n" + jsonString + "\n}}}")
    }
    NSLog("collectMessage: exit: jsonString = {{{\n" + jsonString + "\n}}}")
    return jsonString
}

struct JsonMessage: Codable {
    let emailAddress, name, yourImageURL: String
    let measures1, measures2: [JsonMeasures]
}

struct JsonMeasures: Codable {
    let ki, dad, pulse: Double
    let date: String
}
