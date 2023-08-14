import UIKit

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    //  объекты view-элементов
    @IBOutlet weak var yourAvatarImageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var stateAuthLabel: UILabel!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var regisLoginStackView: UIStackView!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var authInfoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    var userDefaultsManager = UserDefaultsManager()
    var fireBaseAuthManager = FireBaseAuthManager()
    var fireBaseCloudManager = FireBaseCloudManager()
    var coreDataManager = CoreDataManager()
    let TAG = "ProfileViewController: "
    
    
    // MARK: при запуске экрана...
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
        updateViewsVC()
        
        NSLog(TAG + "viewWillAppear: exit")
    }

    // MARK: действия при успешном входе
    func authTrueAction(){
        NSLog(TAG + "authTrueAction: entrance")
        
        stateAuthLabel.text = "You loggined as " + self.userDefaultsManager.getYourEmail()
        nameTextField.text = userDefaultsManager.getYourName()
        authInfoLabel.text = "Click on the red button to logout"
        logoutButton.isHidden = false
        regisLoginStackView.isHidden = true
        nameStackView.isHidden = false
        
        NSLog(TAG + "authTrueAction: exit")
    }
    
    // MARK: действия при НЕ успешном входе
    func authFalseAction(){
        NSLog(TAG + "authFalseAction: entrance")
        
        stateAuthLabel.text = "Log in or register in the system"
        nameTextField.text = ""
        authInfoLabel.text = "Log in if you already have an account, or register"
        logoutButton.isHidden = true
        regisLoginStackView.isHidden = false
        nameStackView.isHidden = true
        
        NSLog(TAG + "authFalseAction: exit")
    }
    
    // MARK: отображение аватарки
    func viewAvatar(){
        NSLog(TAG + "viewAvatar: entrance")
        guard let apiURL = URL(string: self.userDefaultsManager.getYourImageURL()) else {
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
        NSLog(TAG + "viewAvatar: exit")
    }
    
    // MARK: обновление view
    func updateViewsVC(){
        NSLog(TAG + "uploudViewsVC: entrance")
        if fireBaseAuthManager.stateAuth() {
            NSLog(TAG + "settingsViews: stateAuth = true")
            authTrueAction()
        } else {
            NSLog(TAG + "settingsViews: stateAuth = false")
            authFalseAction()
        }
        
        NSLog(TAG + "uploudViewsVC: PASS = " + (coreDataManager.getPass() ?? "---"))
        NSLog(TAG + "uploudViewsVC: exit")
    }
    
    // MARK: кнопка смены имени нажата
    @IBAction func renameButtonClicked(_ sender: Any) {
        NSLog(TAG + "renameButtonClicked: exit: userDefaultsManager?.getYourName = " + (userDefaultsManager.getYourName()))
        userDefaultsManager.saveYourName(name: nameTextField.text ?? "")
        fireBaseCloudManager.updateNameInCloudData()
        NSLog(TAG + "renameButtonClicked: exit: userDefaultsManager?.getYourName = " + (userDefaultsManager.getYourName()))
    }
    
    // MARK: кнопка выхода нажата
    @IBAction func logoutButtonClicked(_ sender: Any) {
        //  вывод alertDialog
        let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToGetOut", comment: ""), message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: NSLocalizedString("ExitInAlertDialog", comment: ""), style: .destructive) { [weak self] (_) in
            NSLog(self!.TAG + "loginAction: logoutAction: entrance")
            self!.fireBaseAuthManager.logOut()
            //self!.userDefaultsManager.deleteUserInfo()
            //self!.coreDataManager.deletePass()
            self!.updateViewsVC()
        }
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive) { [weak self] (_) in
            NSLog(self!.TAG + "loginAction: deleteAccountAction: entrance")
            self!.fireBaseCloudManager.deleteInCloudData()
            self!.fireBaseAuthManager.deleteAccount(using: self!.deleteAccountCompletionHandler)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelInAlertDialog", comment: ""), style: .cancel, handler: nil)
        alert.addAction(logoutAction)
        alert.addAction(deleteAccountAction)
        alert.addAction(cancelAction)
        //  для ipad'ов
        if let popover = alert.popoverPresentationController{
            NSLog("MainViewCon: loginAction: popoverPresentationController: for ipad's")
            popover.sourceView = loginButton
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: результат удаление аккаунта
    lazy var deleteAccountCompletionHandler: (Int, String) -> Void = { doneWorking, desc in
        NSLog(self.TAG + "loginCompletionHandler: entrance")
        switch doneWorking {
        case 0: //  удачное удаление
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = 0")
            self.userDefaultsManager.deleteUserInfo()
            self.coreDataManager.deletePass()
            self.updateViewsVC()
        case 1: //  неудачное удаление
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = 1")
            let alert = UIAlertController(title: "Error when deleting a user", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "loginCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                popover.sourceView = self.loginButton
            }
            self.present(alert, animated: true, completion: nil)
        default:
            NSLog(self.TAG + "loginCompletionHandler: doneWorking = " + String(doneWorking))
        }
    
        NSLog(self.TAG + "loginCompletionHandler: exit")
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
            
        logoutButton.isHidden = true
        regisLoginStackView.isHidden = true
        nameStackView.isHidden = true
        yourAvatarImageView.layer.cornerRadius = yourAvatarImageView.frame.size.width/2
        yourAvatarImageView.clipsToBounds = true
        
        NSLog(TAG + "settingsViews: exit")
    }
    
    // MARK: состояние интернета
    // наблюдение за ним
    func checkingReachability() async{
        while (true){
            switch userDefaultsManager.getStateInternet(){
            case 1:
                registrationButton.isEnabled = true
                loginButton.isEnabled = true
                logoutButton.isEnabled = true
            case 0:
                registrationButton.isEnabled = false
                loginButton.isEnabled = false
                logoutButton.isEnabled = false
            default:
                registrationButton.isEnabled = false
                loginButton.isEnabled = false
                logoutButton.isEnabled = false
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
}
