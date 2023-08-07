import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var registerStackTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailWorningLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordWorningLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameWorningLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    
    
    
    var userDefaultsManager = UserDefaultsManager()
    var fireBaseAuthManager = FireBaseAuthManager()
    var fireBaseCloudManager = FireBaseCloudManager()
    let TAG = "RegisterViewController: "
    var emailValid = false
    var passValid = false
    var nameValid = false

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
    
    // MARK: нажатие на кнопку регистрации
    @IBAction func RegisterButtonClicked(_ sender: Any) {
        NSLog(TAG + "RegisterButtonClicked: entrance")
        if emailValid && passValid && nameValid {
            NSLog(TAG + "RegisterButtonClicked: emailValid && passValid && nameValid == true")
            fireBaseAuthManager.auth(
                email: emailTextField.text!,
                pass: passwordTextField.text!,
                using: registerCompletionHandler
            )
            loginActivityIndicator.isHidden = false
        } else {
            NSLog(TAG + "RegisterButtonClicked: emailValid && passValid && nameValid == false")
            if emailTextField.text == "" {
                emailWorningLabel.isHidden = false
            }
            if passwordTextField.text == "" {
                passwordWorningLabel.isHidden = false
            }
            if nameTextField.text == "" {
                nameWorningLabel.isHidden = false
            }
        }
    }
    
    // MARK: результат регистрации
    lazy var registerCompletionHandler: (Int, String) -> Void = { doneWorking, desc in
        NSLog(self.TAG + "registerCompletionHandler: entrance")
        switch doneWorking {
        case 0: //  удачная регистрация
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = 0")
            self.userDefaultsManager.saveYourEmail(emailAddress: self.emailTextField.text ?? "")
            self.userDefaultsManager.savePassword(password: self.passwordTextField.text ?? "")
            self.userDefaultsManager.saveYourName(name: self.nameTextField.text ?? "")
            self.fireBaseCloudManager.addUserInCloudData()
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = 1: stateAuth() = " + String(self.fireBaseAuthManager.stateAuth()))
            self.loginActivityIndicator.isHidden = true
            self.navigationController?.popViewController(animated: true)
        case 1: //  неудачная регистрация
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = " + String(doneWorking))
            let alert = UIAlertController(title: "Error: " + desc, message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "registerCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.registerButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        case 2: //  пользователь уже существует
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = 2")
            let alert = UIAlertController(title: "This user already exists", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "registerCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.registerButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        case 3:
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = 2")
            let alert = UIAlertController(title: "Check your internet connection", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "registerCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.registerButton
            }
            self.loginActivityIndicator.isHidden = true
            self.present(alert, animated: true, completion: nil)
        default:
            self.loginActivityIndicator.isHidden = true
            NSLog(self.TAG + "registerCompletionHandler: doneWorking = " + String(doneWorking))
        }
    
        NSLog(self.TAG + "registerCompletionHandler: exit")
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
            NSLog(TAG + "passTextFieldChanged: passValid = true")
            passValid = true
            passwordWorningLabel.isHidden = true
        } else {
            NSLog(TAG + "passTextFieldChanged: passValid = false")
            passValid = false
            passwordWorningLabel.text = "The password must be at least 8 characters and do not contain spaces"
            passwordWorningLabel.isHidden = false
        }
    }
    
    // MARK: поле ввода имени изменено
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        NSLog(TAG + "nameTextFieldChanged: entrance: userDefaultsManager?.getYourName = " + (userDefaultsManager.getYourName()))
        nameWorningLabel.isHidden = true
        if (!nameTextField.text!.isEmpty){
            NSLog(TAG + "passTextFieldChanged: !nameTextField.text!.isEmpty = true")
            nameValid = true
            nameWorningLabel.isHidden = true
        } else {
            NSLog(TAG + "passTextFieldChanged: !nameTextField.text!.isEmpty = false")
            nameValid = false
            nameWorningLabel.text = "Enter a name"
            nameWorningLabel.isHidden = false
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
                registerButton.isEnabled = true
            case 0:
                registerButton.isEnabled = false
            default:
                registerButton.isEnabled = false
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}
