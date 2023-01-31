import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    //  объекты view-элементов
    @IBOutlet weak var trainerEmailErrorLabel: UILabel!
    @IBOutlet weak var trainerEmailTextField: UITextField!
    @IBOutlet weak var yourAvatarImageView: UIImageView!
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var stateLogin = false  //  состояние логина: false - нет входа в аккаунт
    var storageYourEmailData = StorageYourEmailData()
    var googleSignJob = GoogleSignInJob()
    
    // MARK: при запуске экрана...
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ProfileViewCon: viewDidLoad: entrance")

        settingsViews() //  ...настройка view 
     
        NSLog("ProfileViewCon: viewDidLoad: exit")
    }
    
    // MARK: отображение экрана
    override func viewDidAppear(_ animated: Bool) {
        NSLog("ProfileViewCon: viewDidAppear: entrance")
        
        Task {
            NSLog("ProfileViewCon: viewDidAppear: Task")
            await checkingReachability()
        }
        
        NSLog("ProfileViewCon: viewWillAppear: exit")
    }
    
    // MARK: состояние интернета
    // наблюдение за ним
    func checkingReachability() async{
        
        while (true){
            switch storageYourEmailData.getStateInternet(){
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
    
    // MARK: нажатие на кнопку входа
    @IBAction func LoginButtonClicked(_ sender: Any) {
        NSLog("ProfileViewCon: LoginButtonClicked: entrance: stateLogin = " + String(stateLogin))
        if stateLogin {
            NSLog("ProfileViewCon: LoginButtonClicked: stateLogin = true: entrance")
            //  вывод alertDialog
            let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToGetOut", comment: ""), message: nil, preferredStyle: .actionSheet)
            let logoutAction = UIAlertAction(title: NSLocalizedString("ExitInAlertDialog", comment: ""), style: .destructive) { [weak self] (_) in
                NSLog("MainViewCon: clickClearButton: delateAction: entrance")
                self!.googleSignJob.logout()   //  очистка графика и данных из бд
                self!.yourAvatarImageView.isHidden = true
                self!.yourNameLabel.text = "The name will be displayed after authorization"
                self!.loginButton.tintColor = UIColor(named: "accentColor2")
                self!.loginButton.setTitle(NSLocalizedString("loginButtonTextLogin", comment: ""), for: UIControl.State.normal)
                self!.stateLogin = false
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancelInAlertDialog", comment: ""), style: .cancel, handler: nil)
            alert.addAction(logoutAction)
            alert.addAction(cancelAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog("MainViewCon: clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = loginButton
            }
            present(alert, animated: true, completion: nil)
        } else {
            NSLog("ProfileViewCon: LoginButtonClicked: stateLogin = false: entrance")
            googleSignJob.login(vc: self, using: loginCompletionHandler)
            stateLogin = true
        }
    }
    
    // MARK: результат авторизации
    lazy var loginCompletionHandler: (Bool) -> Void = { doneWorking in
        NSLog("MainViewCon: loginCompletionHandler: entrance")
        if doneWorking {
            NSLog("MainViewCon: loginCompletionHandler: true")
            self.loginButton.setTitle(NSLocalizedString("loginButtonTextLogout", comment: "") + self.storageYourEmailData.getYourEmailAddress(), for: UIControl.State.normal)
            self.loginButton.tintColor = UIColor(named: "redColor")
            self.viewAvatar()
            self.yourNameLabel.text = self.storageYourEmailData.getYourName()
            self.yourNameLabel.isHidden = false
        } else {
            NSLog("MainViewCon: loginCompletionHandler: false")
            
        }

        NSLog("MainViewCon: loginCompletionHandler: exit")
    }
    
    // MARK: отображение аватарки
    func viewAvatar(){
        NSLog("ProfileViewCon: viewAvatar: entrance")
        guard let apiURL = URL(string: self.storageYourEmailData.getYourImageURL()) else {
            fatalError("some error")
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: apiURL) { (data, response, error) in
            guard let data = data, error == nil else {return}
            DispatchQueue.main.async {
                self.yourAvatarImageView.image = UIImage(data: data)
            }
        }
        task.resume()
        yourAvatarImageView.isHidden = false
        NSLog("ProfileViewCon: viewAvatar: exit")
    }
    
    
    
    // MARK: проверка введенной почты на виладность
    func invalidEmail(_ email: String) -> String?{
        NSLog("ProfileViewCon: invalidEmail: entrance")
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: email){    //  если почта невалидная
            NSLog("ProfileViewCon: invalidEmail: mail is invalid")
            return "Incorrect email"
        }
        NSLog("ProfileViewCon: invalidEmail: exit: mail is valid")
        return nil
    }
    
    // MARK: изменение textField почты тренера
    @IBAction func trainerEmailChanged(_ sender: Any) {
        NSLog("ProfileViewCon: trainerEmailChanged: entrance")
        if let trainerEmail = trainerEmailTextField.text{
            NSLog("ProfileViewCon: trainerEmailChanged: entered mail " + trainerEmail)
            if let errorMessage = invalidEmail(trainerEmail){    //  если почта невалидная
                NSLog("ProfileViewCon: trainerEmailChanged: errorMessage " + errorMessage)
                trainerEmailErrorLabel.text = errorMessage + ", it will not be saved"
                storageYourEmailData.saveTrainerEmailAddress(emailAddress:"")
                storageYourEmailData.saveStateTrainerEmailAddress(state: false)
                trainerEmailErrorLabel.isHidden = false
            }else{
                trainerEmailErrorLabel.isHidden = true
                storageYourEmailData.saveTrainerEmailAddress(emailAddress: trainerEmail)
                storageYourEmailData.saveStateTrainerEmailAddress(state: true)
            }
        }
    }
    
    // MARK: настройка view
    func settingsViews(){
        NSLog("ProfileViewCon: settingsViews: entrance")
        //  настройка statusBar
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(named: "accentColor")
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        stateLogin = storageYourEmailData.getStateLogin()
        NSLog("ProfileViewCon: settingsViews: stateLogin = " + String(stateLogin))
        if stateLogin {
            loginButton.tintColor = UIColor(named: "redColor")
            loginButton.setTitle(NSLocalizedString("loginButtonTextLogout", comment: "") + storageYourEmailData.getYourEmailAddress(), for:UIControl.State.normal)
            yourNameLabel.isHidden = false
            yourNameLabel.text = storageYourEmailData.getYourName()
            viewAvatar()
        } else {
            loginButton.tintColor = UIColor(named: "accentColor2")
            loginButton.setTitle(NSLocalizedString("loginButtonTextLogin", comment: ""), for: UIControl.State.normal)
            yourNameLabel.text = "The name will be displayed after authorization"
        }
        
        yourAvatarImageView.layer.cornerRadius = yourAvatarImageView.frame.size.width/2
        yourAvatarImageView.clipsToBounds = true
        trainerEmailTextField.text = storageYourEmailData.getTrainerEmailAddress()
        
        NSLog("ProfileViewCon: settingsViews: exit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        NSLog("ProfileViewCon: prepare:")
    }
}
