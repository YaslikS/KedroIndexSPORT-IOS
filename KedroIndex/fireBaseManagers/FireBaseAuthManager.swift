import Foundation
import FirebaseAuth

class FireBaseAuthManager{
    
    var userDefaultsManager = UserDefaultsManager()
    var emailUser: String!
    let TAG = "FireBaseAuthManager: "
    
    // MARK:  состояние авторизации
    func stateAuth() -> Bool{
        if Auth.auth().currentUser != nil {
            NSLog(TAG + "stateAuth: auth().currentUser != nil / " + (Auth.auth().currentUser?.email)!)
            emailUser = Auth.auth().currentUser?.email
            return true
        } else {
            NSLog(TAG + "stateAuth: auth().currentUser == nil")
            return false
        }
    }
    
    // MARK:  повторная авторизация
    func reAuth(using completionHandler: @escaping (Int, String) -> Void){
        NSLog(TAG + "reAuth: entrance")
        Auth.auth().currentUser?.reauthenticate(with: EmailAuthProvider.credential(withEmail: userDefaultsManager.getYourEmail(), password: userDefaultsManager.getPassword()), completion: { result, error in
            if let error = error {
                //  Произошла ошибка
                NSLog(self.TAG + "reAuth: error: " + error.localizedDescription)
                let errCode = AuthErrorCode(_nsError: error as NSError)
                switch errCode.code {
                case .networkError:             //  ошибка сети
                    NSLog(self.TAG + "reAuth: error: networkError")
                    completionHandler(4, "")
                case .userNotFound:             //  такого пользователя нет
                    NSLog(self.TAG + "reAuth: error: userNotFound")
                    self.logOut()
                    completionHandler(3, "")
                case .wrongPassword:            //  неправильный пароль
                    NSLog(self.TAG + "reAuth: error: wrongPassword")
                    self.logOut()
                    completionHandler(2, "")
                default:                        //  непредвиденная ошибка
                    NSLog(self.TAG + "reAuth: error: default")
                    self.logOut()
                    completionHandler(1, error.localizedDescription)
                }
            } else {
                // Повторная аутентификация пользователя
                completionHandler(0, "")
                NSLog(self.TAG + "reAuth: User re-authenticated")
            }
          })
        NSLog(TAG + "reAuth: exit")
    }
    
    // MARK:  авторизация
    func auth(email: String, pass: String, using completionHandler: @escaping (Int, String) -> Void){
        NSLog(TAG + "auth: entrance")
        Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
            guard error == nil else {
                NSLog(self.TAG + "auth: error = " + error.debugDescription)
                let errCode = AuthErrorCode(_nsError: error! as NSError)
                switch errCode.code {
                case .emailAlreadyInUse:        //  пользователь уже существует
                    NSLog(self.TAG + "reAuth: error: emailAlreadyInUse")
                    completionHandler(2, "")
                case .networkError:             //  ошибка сети
                    NSLog(self.TAG + "reAuth: error: networkError")
                    completionHandler(3, "")
                default:                        //  непредвиденная ошибка
                    NSLog(self.TAG + "reAuth: error: default")
                    completionHandler(1, error!.localizedDescription)
                }
                return
            }
            NSLog(self.TAG + "auth: authResult?.user.email = " + (authResult?.user.email)!)
            guard authResult?.user.email != nil else{
                NSLog(self.TAG + "auth: error = " + error.debugDescription)
                completionHandler(1, error!.localizedDescription)
                return
            }
            NSLog(self.TAG + "auth: success")
            self.userDefaultsManager.saveIdUser(idUser: (authResult?.user.uid)!)
            self.emailUser = authResult?.user.email
            completionHandler(0, "")
        }
    }
    
    // MARK: вход
    func login(email: String, pass: String, using completionHandler: @escaping (Int, String) -> Void){
        NSLog(TAG + "login: entrance")
        //reAuth()
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            guard error == nil else {
                NSLog(self.TAG + "login: error = " + error.debugDescription)

                let errCode = AuthErrorCode(_nsError: error! as NSError)
                switch errCode.code {
                case .networkError:             //  ошибка сети
                    NSLog(self.TAG + "reAuth: error: networkError")
                    completionHandler(4, "")
                case .userNotFound:             //  такого пользователя нет
                    NSLog(self.TAG + "reAuth: error: userNotFound")
                    completionHandler(3, "")
                case .wrongPassword:            //  неправильный пароль
                    NSLog(self.TAG + "reAuth: error: wrongPassword")
                    completionHandler(2, "")
                default:                        //  непредвиденная ошибка
                    NSLog(self.TAG + "reAuth: error: default")
                    completionHandler(1, error!.localizedDescription)
                }
                return
            }
            NSLog(self.TAG + "login: success")
            NSLog(self.TAG + "login: authResult?.user.email = " + (authResult?.user.email)!)
            self.userDefaultsManager.saveIdUser(idUser: (authResult?.user.uid)!)
            self.emailUser = authResult?.user.email!
            completionHandler(0, "")
        }
    }
    
    // MARK: выход из аккаунта
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            NSLog(TAG + "logOut: succes")
        } catch let signOutError as NSError {
            NSLog(TAG + "logOut: Error signing out: " + signOutError.debugDescription)
        }
    }
    
    // MARK: удаление аккаунта
    func deleteAccount(using completionHandler: @escaping (Int, String) -> Void){
        NSLog("FireBaseAuthManager: deleteAccount: entrance")
        Auth.auth().currentUser?.delete{ error in
            if let error = error {
                //  Произошла ошибка
                NSLog(self.TAG + "deleteAccount: error delete: " + error.localizedDescription)
                completionHandler(1, error.localizedDescription)
            } else {
                //  Учетная запись удалена
                NSLog(self.TAG + "deleteAccount: deleted")
                completionHandler(0, "")
            }
        }
    }
    
    // MARK: сброс пароля
    func resetPass(email: String, using completionHandler: @escaping (Int, String) -> Void) {
        NSLog("resetPass: entrance")
        Auth.auth().sendPasswordReset(withEmail: email){ error in
            if let error = error {
                //  Произошла ошибка
                NSLog(self.TAG + "resetPass: error")
                completionHandler(1, error.localizedDescription)
            } else {
                //  Учетная запись удалена
                NSLog(self.TAG + "resetPass: Successful")
                completionHandler(0, "")
            }
        }
    }
    
    
}
