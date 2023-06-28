import Foundation
import FirebaseAuth

class FireBaseAuthManager{
    
    var userDefaultsManager = UserDefaultsManager()
    var emailUser: String!
    var authWas = false
    let TAG = "FireBaseAuthManager: "
    
    // MARK:  состояние авторизации
    func stateAuth() -> Bool{
        if Auth.auth().currentUser != nil {
            NSLog(TAG + "stateAuth: auth().currentUser != nil")
            emailUser = Auth.auth().currentUser?.email
            return true
        } else {
            NSLog(TAG + "stateAuth: auth().currentUser == nil")
            return false
        }
    }
    
    // MARK:  повторная авторизация
    func reAuth(using completionHandler: @escaping (Int) -> Void){
        Auth.auth().currentUser?.reauthenticate(with: EmailAuthProvider.credential(withEmail: userDefaultsManager.getYourEmail(), password: userDefaultsManager.getPassword()), completion: { result, error in
            if let error = error {
                // An error happened.
                completionHandler(0)
                NSLog(self.TAG + "reAuth: error: " + error.localizedDescription)
            } else {
                // User re-authenticated.
                completionHandler(1)
                NSLog(self.TAG + "reAuth: User re-authenticated")
            }
          })
    }
    
    // MARK:  авторизация
    func auth(email: String, pass: String, using completionHandler: @escaping (Int) -> Void){
        NSLog(TAG + "auth: entrance")
        Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
            guard error == nil else {
                NSLog(self.TAG + "auth: error = " + error.debugDescription)
                print(error as Any)
                completionHandler(0)
                return
            }
            guard authResult?.user.email != nil else{
                NSLog(self.TAG + "auth: error = " + error.debugDescription)
                NSLog(self.TAG + "auth: authResult?.user.email = " + (authResult?.user.email)!)
                completionHandler(0)
                return
            }
            NSLog(self.TAG + "auth: authResult?.user.email = " + (authResult?.user.email)!)
            self.userDefaultsManager.saveIdUser(idUser: (authResult?.user.uid)!)
            self.emailUser = authResult?.user.email
            self.authWas = true
            self.login(email: email, pass: pass, using: completionHandler)
        }
    }
    
    // MARK: вход
    func login(email: String, pass: String, using completionHandler: @escaping (Int) -> Void){
        NSLog(TAG + "login: entrance")
        //reAuth()
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            guard error == nil else {
                NSLog(self.TAG + "login: error = " + error.debugDescription)
                print(error as Any)
                self.auth(email: email, pass: pass, using: completionHandler)
                return
            }
            NSLog(self.TAG + "login: authResult?.user.email = " + (authResult?.user.email)!)
            self.userDefaultsManager.saveIdUser(idUser: (authResult?.user.uid)!)
            self.emailUser = authResult?.user.email!
            completionHandler(1)
        }
    }
    
    // MARK: выход из аккаунта
    func logOut() {
        do {
            try Auth.auth().signOut()
            //NSLog("FireBaseAuthManager: logOut: Error signing out: " + Auth.auth().currentUser!.uid)
        } catch let signOutError as NSError {
            NSLog(TAG + "logOut: Error signing out: " + signOutError.debugDescription)
        }
    }
    
    // MARK: удаление аккаунта
    func deleteAccount(){
        NSLog("FireBaseAuthManager: deleteAccount: entrance")
        //logOut()
        Auth.auth().currentUser?.delete{ error in
            if let error = error {
                // An error happened.
                NSLog(self.TAG + "deleteAccount: error delete: " + error.localizedDescription)
            } else {
                // Account deleted.
                NSLog(self.TAG + "deleteAccount: deleted")
            }
        }
    }

}
