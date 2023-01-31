import GoogleSignIn

// TODO: Перенос ВСЕЙ логики регистрации сюда
class GoogleSignInJob{
    
    let signInConfig = GIDConfiguration(clientID: "118860555682-71e32ovelkuuoococbivdpeh9ulna65g.apps.googleusercontent.com")
    var yourMail = String()
    var storageYourEmailData = StorageYourEmailData()
    
    // MARK: вход в аккаунт
    func login(vc: UIViewController, using completionHandler: @escaping (Bool) -> Void){
        NSLog("ProfileViewCon: Login: entrance")
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
            NSLog("ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: entrance")
            guard error == nil else { return }
            // If sign in succeeded, display the app's main content View.
            guard let userS = user else { return }

            self.yourMail = userS.profile!.email
            self.storageYourEmailData.saveYourEmailAddress(emailAddress: self.yourMail)
            self.storageYourEmailData.saveFullName(fullName: userS.profile!.name)
            self.storageYourEmailData.saveYourName(name: userS.profile!.name)
            self.storageYourEmailData.saveYourImageURL(yourImageURL: userS.profile!.imageURL(withDimension: 320)?.absoluteString ?? "")
            NSLog("ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: data saved")

            userS.authentication.do { authentication, error in
                guard error == nil else { return }
                guard authentication != nil else { return }
                self.storageYourEmailData.saveAccessToken(accessToken: userS.authentication.accessToken)
                
                NSLog(
                    "ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: accessToken saved = "
                    + self.storageYourEmailData.getAccessToken()
                )
            }
            NSLog("ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: emailAddress = " + self.yourMail)
            NSLog(
                "ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: fullName = "
                + self.storageYourEmailData.getFullName()
            )
            NSLog(
                "ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: profilePicUrl = "
                + self.storageYourEmailData.getYourImageURL()
            )

            self.addScopes(vc: vc)
            self.storageYourEmailData.saveStateLogin(state: true)
            completionHandler(true)
            NSLog("ProfileViewCon: Login: GIDSignIn.sharedInstance.signIn: exit")
        }
        NSLog("ProfileViewCon: Login: exit")
    }
    
    // MARK: добавление разрешений на доступ
    // к сервисам Google
    func addScopes(vc: UIViewController) {
        NSLog("ProfileViewCon: addScopes: entrance")
        //let additionalScopes = ["https://www.googleapis.com/auth/userinfo.profile" ,"https://www.googleapis.com/auth/userinfo.email", "https://mail.google.com","https://www.google.com/m8/feeds/"]
        let additionalScopes = ["https://www.googleapis.com/auth/gmail.send","https://www.googleapis.com/auth/gmail.settings.basic"]
        GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: vc) { user, error in
            guard error == nil else { return }
            guard user != nil else { return }
        }
        NSLog("ProfileViewCon: addScopes: exit")
    }
    
    // MARK: реавторизация
    func ReAuthentication() {
        NSLog("ReAuthentication: entrance")
        let storageYourEmailData = StorageYourEmailData()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                NSLog("ReAuthentication: signed-OUT state")
            } else {
                // Show the app's signed-in state.
                NSLog("ReAuthentication: signed-IN state")
            }
        
            user?.authentication.do { authentication, error in
                guard error == nil else { return }
                guard authentication != nil else { return }
                storageYourEmailData.saveAccessToken(accessToken: user?.authentication.accessToken ?? "")
                NSLog(
                    "ReAuthentication: authentication.do: accessToken saved = "
                    + storageYourEmailData.getAccessToken()
                )
            }
        }
        
        Task{
            NSLog("ReAuthentication: Task")
            await ReAuthenticationEveryHalfHour()
        }
    NSLog(" ReAuthentication: exit")
    }

    // MARK: реавторизация каждые полчаса
    func ReAuthenticationEveryHalfHour() async {
        NSLog("ReAuthentication: ReAuthenticationEveryHalfHour: entrance")
        while true {
            try? await Task.sleep(nanoseconds: 1800_000_000_000)
            ReAuthentication()
        }
    }
    
    // MARK: выход из аккаунта
    func logout() {
        NSLog("ProfileViewCon: logout: entrance")
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.disconnect { error in
            NSLog("ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: entrance")
            guard error == nil else { return }
            self.storageYourEmailData.saveYourImageURL(yourImageURL: "")
            self.storageYourEmailData.saveFullName(fullName: "")
            self.storageYourEmailData.saveIdMessage(idMessage: 0)
            self.storageYourEmailData.saveAccessToken(accessToken: "")
            self.storageYourEmailData.saveYourEmailAddress(emailAddress: "")
            self.storageYourEmailData.saveStateLogin(state: false)
            NSLog(
                "ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: profilePicUrl = "
                + self.storageYourEmailData.getYourImageURL()
            )
            NSLog(
                "ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: fullName = "
                + self.storageYourEmailData.getFullName()
            )
            NSLog(
                "ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: IdMessage = "
                + String(self.storageYourEmailData.getIdMessage())
            )
            NSLog(
                "ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: accessToken saved = "
                + self.storageYourEmailData.getAccessToken()
            )
            NSLog(
                "ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: YourEmailAddress = "
                + self.storageYourEmailData.getYourEmailAddress()
            )
            NSLog("ProfileViewCon: logout: GIDSignIn.sharedInstance.disconnect: emailAddress = " + self.yourMail)
        }
        NSLog("ProfileViewCon: logout: exit")
    }

}
