import Foundation
import FirebaseFirestore

class FireBaseCloudManager {
    
    var userDefaultsManager = UserDefaultsManager()
    var db: Firestore!
    let TAG = "FireBaseCloudManager: "
    
    init(){
        db = Firestore.firestore()
    }
    
    // MARK: создание пользователя
    func addUserInCloudData(){
        NSLog(TAG + "addUserInCloudData: entrance")
        var jsonForUpdate = ""
        if userDefaultsManager.getJson() != "empty"{
            jsonForUpdate = userDefaultsManager.getJson()
        }
        
        let idUser = userDefaultsManager.getIdUser()
        let yourName = userDefaultsManager.getYourName()
        let yourEmail = userDefaultsManager.getYourEmail()
        let yourUrl = userDefaultsManager.getYourImageURL()
        let lastDate = userDefaultsManager.getLastDate()
        NSLog(TAG + "addUserInCloudData: userDefaultsManager.getIdUser = " + idUser)
        
        db.collection("users").document(idUser).setData([
            "id": idUser,
            "type": "s",
            "name": yourName,
            "email": yourEmail,
            "iconUrl": yourUrl,
            "trainerId": "",
            "lastDate": lastDate,
            "json": jsonForUpdate,
            "settings": "",
            "f1": "",
            "f2": "",
            "f3": "",
            "f4": "",
            "f5": ""
        ])
        NSLog(TAG + "addUserInCloudData: exit")
    }
    
    // MARK:  обновление json с измерениями
    func updateJsonInCloudData(){
        NSLog(TAG + "updateJsonInCloudData: entrance: userDefaultsManager.getIdUser = " + userDefaultsManager.getIdUser())
        var jsonForUpdate = ""
        if userDefaultsManager.getJson() != "empty"{
            jsonForUpdate = userDefaultsManager.getJson()
        }
        db.collection("users")
            .document(userDefaultsManager.getIdUser())
            .updateData(["json": jsonForUpdate]){ error in
                if let error = error {
                    NSLog(self.TAG + "updateJsonInCloudData: Error updating document: \(error.localizedDescription)")
                } else {
                    NSLog(self.TAG + "updateJsonInCloudData: Document successfully updated")
                }
            }
    }
    
    // MARK:  обновление даты последнего обновления бд
    func updateLastDateInCloudData(){
        NSLog(TAG + "updateLastDateInCloudData: entrance: userDefaultsManager.getLastDate = " + userDefaultsManager.getLastDate())
        db.collection("users").document(userDefaultsManager.getIdUser())
            .updateData(["lastDate": userDefaultsManager.getLastDate()]){ error in
                if let error = error {
                    NSLog(self.TAG + "updateLastDateInCloudData: Error updating document: \(error.localizedDescription)")
                } else {
                    NSLog(self.TAG + "updateLastDateInCloudData: Document successfully updated")
                }
            }
    }
    
    // MARK:  обновление имени
    func updateNameInCloudData(){
        NSLog(TAG + "updateNameInCloudData: entrance: userDefaultsManager.getYourName = " + userDefaultsManager.getYourName())
        db.collection("users").document(userDefaultsManager.getIdUser())
            .updateData(["name": userDefaultsManager.getYourName()]){ error in
                if let error = error {
                    NSLog(self.TAG + "updateNameInCloudData: Error updating document: \(error.localizedDescription)")
                } else {
                    NSLog(self.TAG + "updateNameInCloudData: Document successfully updated")
                }
            }
    }
    
    // MARK:  обновление url иконки
    func updateUrlIconInCloudData(){
        NSLog(TAG + "updateUrlIconInCloudData: entrance: userDefaultsManager.getYourImageURL = " + userDefaultsManager.getYourImageURL())
        db.collection("users")
            .document(userDefaultsManager.getIdUser())
            .updateData(["iconUrl": userDefaultsManager.getYourImageURL()]){ error in
                if let error = error {
                    NSLog(self.TAG + "updateUrlIconInCloudData: Error updating document: \(error.localizedDescription)")
                } else {
                    NSLog(self.TAG + "updateUrlIconInCloudData: Document successfully updated")
                }
            }
    }
    
    // MARK:  удаление пользователя
    func deleteInCloudData(){
        NSLog(TAG + "deleteInCloudData: entrance: userDefaultsManager.getIdUser = " + userDefaultsManager.getIdUser())
        db.collection("users").document(userDefaultsManager.getIdUser())
            .delete(){ error in
            if error != nil {
                NSLog(self.TAG + "deleteInCloudData: error = " + error!.localizedDescription)
            }
        }
        NSLog(TAG + "deleteInCloudData: exit")
    }
    
    // MARK:  получение данных пользователя
    func getCloudData(){
        db.collection("users").document(userDefaultsManager.getIdUser())
            .getDocument{ (document, error) in
            if let document = document, document.exists {
                self.syncData(result: document)
                let name = document.get("name") as! String
                self.userDefaultsManager.saveYourName(name: name)
            } else {
                NSLog(self.TAG + "getCloudData: Document does not exist")
            }
        }
    }
    
    // MARK: синхронизация данных между сервером и телефоном
    func syncData(result: DocumentSnapshot){
        NSLog(TAG + "syncData: entrance")
        if (result.get("lastDate") as! String) == "" {   //  если облако пустое
            NSLog(TAG + "syncData: cloud is empty")
            updateJsonInCloudData()
            updateLastDateInCloudData()
        } else {    //  если облако НЕ пустое
            if userDefaultsManager.getLastDate() != "" {    //  телефон НЕ пуст
                let resultOfComparison = dataComparison(result: result)
                if resultOfComparison! > 0 {     //  облако актуальнее телефона
                    NSLog(TAG + "syncData: resultOfComparison! > 0")
                    userDefaultsManager.saveLastDate(lastDate: result.get("lastDate") as! String)
                    userDefaultsManager.saveJson(json: result.get("json") as! String)
                } else if resultOfComparison! < 0 { //  телефон актуальнее облака
                    NSLog(TAG + "syncData: resultOfComparison! < 0")
                    updateJsonInCloudData()
                    updateLastDateInCloudData()
                } else {
                    NSLog(TAG + "syncData: dates equal")
                }
            } else {    //  телефон пуст
                NSLog(TAG + "syncData: phone is empty")
                userDefaultsManager.saveLastDate(lastDate: result.get("lastDate") as! String)
                userDefaultsManager.saveJson(json: result.get("json") as! String)
            }
        }
    }
    
    // MARK:  сравнение дат
    func dataComparison(result: DocumentSnapshot) -> Int?{
        NSLog(TAG + "dataComparison: entrance")
        guard let cloudDate = (result.get("lastDate") as! String).toDate() else {
            NSLog(TAG + "dataComparison: dateString1: \(String(describing: result.get("lastDate"))) | Failed to cast to \"dd.MM.yyyy HH:mm:ss\"")
            return nil
        }
        guard let phoneDate = userDefaultsManager.getLastDate().toDate() else {
            NSLog(TAG + "dataComparison: dateString2: \(userDefaultsManager.getLastDate()) | Failed to cast to \"dd.MM.yyyy HH:mm:ss\"")
            return nil
        }
        
        let isDescending = cloudDate.compare(phoneDate) == ComparisonResult.orderedDescending
        if isDescending {
            NSLog(TAG + "dataComparison: cloud more relevant than phone")
            return 1    //  положительное, если облако актуальнее телефона
        }
        let isAscending = cloudDate.compare(phoneDate) == ComparisonResult.orderedAscending
        if isAscending {
            NSLog(TAG + "dataComparison: phone more relevant than cloud")
            return -1   //  отрицательное, если телефон актуальнее облака
        }
        NSLog(TAG + "dataComparison: dates equal")
        return 0        //  если равны
    }
    
    // MARK: получение типа пользователя
    func getTypeUser(email: String, using completionHandler: @escaping (Int, String?) -> Void){
        db.collection("users").whereField(
            "email", isEqualTo: email
        ).getDocuments{ (documents, error) in
            if let error = error {
                NSLog(self.TAG + "getCloudData: Error getting documents: \(error)")
                completionHandler(0, nil)
            } else {
                if (documents!.isEmpty) {
                    NSLog(self.TAG + "getCloudData: documents?.isEmpty")
                    completionHandler(0, nil)
                } else {
                    let typeStr = documents!.documents[0].get("type") as! String
                    //let typeStr = document!.get("type") as! String
                    completionHandler(1, typeStr)
                }
            }
        }
    }
    
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.date(from: self)
    }
}
