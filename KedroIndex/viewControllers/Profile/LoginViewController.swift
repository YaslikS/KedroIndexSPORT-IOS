import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailWorningLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordWorningLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    var userDefaultsManager = UserDefaultsManager()
    var fireBaseAuthManager = FireBaseAuthManager()
    var fireBaseCloudManager = FireBaseCloudManager()
    var coreDataManager = CoreDataManager()
    let TAG = "LoginViewController: "
    var emailValid = false
    var passValid = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog(TAG + "viewDidLoad: entrance")
    
        settingsViews() //  ...настройка view
        
        NSLog(TAG + "viewDidLoad: exit")
    }
    
    // MARK: отображение экрана
    override func viewDidAppear(_ animated: Bool) {
        NSLog(TAG + "viewDidAppear: entrance")
        
        Task {
            NSLog(TAG + "viewDidAppear: Task")
            await checkingReachability()
        }
        
        NSLog(TAG + "viewWillAppear: exit")
    }
    
    // MARK: нажатие на кнопку сброса пароля
    @IBAction func forgotPassButtonClicked(_ sender: Any) {
        NSLog(TAG + "forgotPassButtonClicked: entrance")
        if emailValid {
            NSLog(TAG + "RegisterButtonClicked: emailValid = " + String(emailValid))
            fireBaseAuthManager.resetPass(
                email: emailTextField.text!,
                using: resetPassCompletionHandler
            )
        } else {
            NSLog(TAG + "RegisterButtonClicked: emailValid = " + String(emailValid))
            let alert = UIAlertController(title: "Enter your email address to which the password reset message will be sent", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.forgotPasswordButton
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: нажатие на кнопку входа
    @IBAction func loginButtonClicked(_ sender: Any) {
        NSLog(TAG + "RegisterButtonClicked: entrance")
        if emailValid && passValid {
            NSLog(TAG + "LoginButtonClicked: emailValid && passValid && nameValid == true")
            fireBaseAuthManager.login(email: emailTextField.text!,
                                      pass: passwordTextField.text!,
                                      using: loginCompletionHandler
            )
            loginActivityIndicator.isHidden = false
        } else {
            NSLog(TAG + "LoginButtonClicked: emailValid && passValid && nameValid == false")
            if emailTextField.text == "" {
                emailWorningLabel.isHidden = false
            }
            if passwordTextField.text == "" {
                passwordWorningLabel.isHidden = false
            }
        }
    }
    
    // MARK: результат сброса пароля
    lazy var resetPassCompletionHandler: (Int, String) -> Void = { doneWorking, desc in
        NSLog(self.TAG + "loginCompletionHandler: entrance")
        switch doneWorking {
        case 0: //  удачный вход
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
            let alert = UIAlertController(title: "We have sent instructions on how to reset your password to your email!", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.forgotPasswordButton
            }
            self.present(alert, animated: true, completion: nil)
        case 1: //  неудачный вход
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
            let alert = UIAlertController(title: "Error sending email: " + desc, message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.forgotPasswordButton
            }
            self.present(alert, animated: true, completion: nil)
        default:
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
        }
    
        NSLog(self.TAG + "loginCompletionHandler: exit")
    }
    
    // MARK: результат входа
    lazy var loginCompletionHandler: (Int, String) -> Void = { doneWorking, desc in
        NSLog(self.TAG + "loginCompletionHandler: entrance")
        switch doneWorking {
        case 0: //  удачный вход
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = 0")
            //  проверка на тип пользователя
            self.fireBaseCloudManager.getTypeUser(
                email: self.emailTextField.text!,
                using: self.typeUserCompletionHandler
            )
        case 1: //  неудачный вход
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
            let alert = UIAlertController(title: "Error: " + desc, message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        case 2: //  неправильный пароль
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = 2")
            let alert = UIAlertController(title: "Incorrect password", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        case 3: //  такого пользователя нет
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = 3")
            let alert = UIAlertController(title: "There is no such user", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        case 4:
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = 2")
            let alert = UIAlertController(title: "Check your internet connection", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "registerCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        default:
            self.loginActivityIndicator.isHidden = true
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
        }
    
        NSLog(self.TAG + "loginCompletionHandler: exit")
    }
    
    // MARK: результат проверки на тип пользователя
    lazy var typeUserCompletionHandler: (Int, String?) -> Void = { doneWorking, typeUser in
        NSLog(self.TAG + "typeUserCompletionHandler: entrance")
        switch doneWorking {
        case 1:  //  удачная проверка
            NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = 1")
            if typeUser == "s" {
                NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = 1: typeUser == s")
                self.fireBaseCloudManager.getCloudData()
                self.userDefaultsManager.saveYourEmail(emailAddress: self.emailTextField.text ?? "")
                self.userDefaultsManager.savePassword(password: self.passwordTextField.text ?? "")// под удаление
                self.coreDataManager.savePass(pass: self.passwordTextField.text ?? "")
                NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = 1: stateAuth() = " + String(self.fireBaseAuthManager.stateAuth()))
                self.loginActivityIndicator.isHidden = true
                self.navigationController?.popViewController(animated: true)
            } else {
                NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = 1: typeUser == t")
                self.fireBaseAuthManager.logOut()
                self.userDefaultsManager.deleteUserInfo()
                let alert = UIAlertController(title: "You are already registered as a trainer", message: nil, preferredStyle: .actionSheet)
                let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                    NSLog(self!.TAG + "typeUserCompletionHandler: UIAlertController: OK")
                }
                alert.addAction(okAction)
                //  для ipad'ов
                if let popover = alert.popoverPresentationController{
                    NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                    popover.sourceView = self.loginButton
                }
                self.loginActivityIndicator.isHidden = true
                self.present(alert, animated: true, completion: nil)
            }
        case 0:
            NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = 0")
            self.fireBaseAuthManager.logOut()
            self.userDefaultsManager.deleteUserInfo()
            let alert = UIAlertController(title: "Error in defining your role", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "typeUserCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        default:
            self.loginActivityIndicator.isHidden = true
            NSLog(self.TAG + "typeUserCompletionHandler: doneWorking = default")
        }
    
    }
    
    // MARK: поле ввода почты изменено
    @IBAction func emailTextFieldChanged(_ sender: Any) {
        NSLog(TAG + "emailTextFieldChanged: userDefaultsManager?.getYourName = " + (userDefaultsManager.getYourName()))
        emailWorningLabel.isHidden = true
        invalidEmail()
    }
    
    // MARK: проверка введенной почты на виладность
    func invalidEmail(){
        NSLog(TAG + "invalidEmail: entrance")
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: emailTextField.text){    //  если почта невалидная
            NSLog(TAG + "invalidEmail: mail is invalid")
            emailWorningLabel.text = "Mail is invalid"
            emailWorningLabel.isHidden = false
            emailValid = false
            return
        }
        NSLog(TAG + "invalidEmail: exit: mail is valid")
        emailWorningLabel.isHidden = true
        emailValid = true
    }
    
    // MARK: поле ввода пароля изменено
    @IBAction func passTextFieldChanged(_ sender: Any) {
        NSLog(TAG + "passTextFieldChanged: userDefaultsManager?.getPassword = " + (userDefaultsManager.getPassword()))
        passwordWorningLabel.isHidden = true
        if (!passwordTextField.text!.isEmpty
            && passwordTextField.text!.count >= 8
            && !passwordTextField.text!.contains(" ")
        ){
            NSLog(TAG + "passTextFieldChanged: !passwordTextField.text!.isEmpty = true")
            passValid = true
            passwordWorningLabel.isHidden = true
        } else {
            NSLog(TAG + "passTextFieldChanged: !passwordTextField.text!.isEmpty = false")
            passValid = false
            passwordWorningLabel.text = "The password must be at least 8 characters and do not contain spaces"
            passwordWorningLabel.isHidden = false
        }
    }
    
    // MARK: настройка view
    func settingsViews(){
        NSLog(TAG + "settingsViews: entrance")
        //  настройка statusBar
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(named: "accentColor")
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        loginActivityIndicator.isHidden = true
        
        NSLog(TAG + "settingsViews: exit")
    }
    
    // MARK: состояние интернета
    // наблюдение за ним
    func checkingReachability() async{
        while (true){
            switch userDefaultsManager.getStateInternet(){
            case 1:
                loginButton.isEnabled = true
            case 0:
                loginButton.isEnabled = false
            default:
                loginButton.isEnabled = false
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}
