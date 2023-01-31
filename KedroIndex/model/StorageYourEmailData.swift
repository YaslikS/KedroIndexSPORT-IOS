import Foundation

class StorageYourEmailData {
    
    // MARK: SAVE
    // имя пользователя
    func saveYourName(name: String){
        UserDefaults.standard.set(name, forKey: "yourName")
    }
    
    // email пользователя
    func saveYourEmailAddress(emailAddress: String){
        UserDefaults.standard.set(emailAddress, forKey: "emailAddress")
    }
    
    // email тренера
    func saveTrainerEmailAddress(emailAddress: String){
        UserDefaults.standard.set(emailAddress, forKey: "emailAddressTrainer")
    }
    
    func saveFullName(fullName: String){
        UserDefaults.standard.set(fullName, forKey: "fullName")
    }
    
    // токен доступа к аккаунту
    func saveAccessToken(accessToken: String){
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
    }
    
    // id последнего сообщения
    func saveIdMessage(idMessage: UInt){
        UserDefaults.standard.set(idMessage, forKey: "idMessage")
    }
    
    // ссылка на аватарку пользователя
    func saveYourImageURL(yourImageURL: String){
        UserDefaults.standard.set(yourImageURL, forKey: "yourImageURL")
    }
    
    // статус авторизации пользователя / true - авторизирован
    func saveStateLogin(state: Bool){
        UserDefaults.standard.set(state, forKey: "stateLogin")
    }
    
    // статус ввода почты тренера / true - введена
    func saveStateTrainerEmailAddress(state: Bool){
        UserDefaults.standard.set(state, forKey: "stateTrainerEmailAddress")
    }
    
    // статус доступности интернета
    // 0 - интернета нет
    // 1 - интернет есть
    // 2 - не используется
    func saveStateInternet(state: Int){
        UserDefaults.standard.set(state, forKey: "stateInternet")
    }
    
    // статус отправки сообщения
    // 0 - еще не загружено
    // 1 - загружено
    // 2 - ошибка загрузки
    // 3 - нет данных для отправки
    func saveStateUpload(state: Int){
        UserDefaults.standard.set(state, forKey: "stateUpload")
    }
    
    
    // MARK: GET
    // имя пользователя
    func getYourName() -> String{
        return UserDefaults.standard.string(forKey: "yourName") ?? ""
    }
    
    // email пользователя
    func getYourEmailAddress() -> String{
        return UserDefaults.standard.string(forKey: "emailAddress") ?? ""
    }
    
    // email тренера
    func getTrainerEmailAddress() -> String{
        return UserDefaults.standard.string(forKey: "emailAddressTrainer") ?? ""
    }
    
    func getFullName() -> String{
        return UserDefaults.standard.string(forKey: "fullName") ?? ""
    }
    
    // токен доступа к аккаунту
    func getAccessToken() -> String{
        return UserDefaults.standard.string(forKey: "accessToken") ?? ""
    }
    
    // id последнего сообщения
    func getIdMessage() -> UInt{
        return UInt(UserDefaults.standard.integer(forKey: "idMessage"))
    }
    
    // ссылка на аватарку пользователя
    func getYourImageURL() -> String{
        return UserDefaults.standard.string(forKey: "yourImageURL") ?? ""
    }
    
    // статус авторизации пользователя / true - авторизирован
    func getStateLogin() -> Bool{
        return UserDefaults.standard.bool(forKey: "stateLogin")
    }
    
    // статус ввода почты тренера / true - введена
    func getStateTrainerEmailAddress() -> Bool{
        return UserDefaults.standard.bool(forKey: "stateTrainerEmailAddress")
    }
    
    // статус доступности интернета
    // 0 - интернета нет
    // 1 - интернет есть
    // 2 - не используется
    func getStateInternet() -> Int{
        return UserDefaults.standard.integer(forKey: "stateInternet")
    }
    
    // статус отправки сообщения
    // 0 - еще не загружено
    // 1 - загружено
    // 2 - ошибка загрузки
    // 3 - не используется
    func getStateUpload() -> Int{
        return UserDefaults.standard.integer(forKey: "stateUpload")
    }
    
}


