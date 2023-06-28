import UIKit

class AboutKerdoIndexViewController: UIViewController {
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var iconAppImageView: UIImageView!
    @IBOutlet weak var nameAppLabel: UILabel!
    @IBOutlet weak var infoAboutAppLabel: UILabel!
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsViews()
        installIconInImageView()
        installValueInNameAppLabel()
        installValueInInfoAboutAppLabel()
    }
    
    func installIconInImageView(){
        iconAppImageView.image = Bundle.main.icon
        iconAppImageView.layer.cornerRadius = 20
        iconAppImageView.clipsToBounds = true
    }
    
    func installValueInNameAppLabel(){
        nameAppLabel.text = "KerdoIndexSPORT " + (appVersion ?? "")
    }
    
    func installValueInInfoAboutAppLabel(){
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let deviceType = UIDevice().name + " / " + UIDevice().systemName + " " + UIDevice().systemVersion
        var infoAboutAppText = "KerdoIndexSPORT " + (appVersion ?? "") + " (" + (buildNumber ?? "") + ") / "
        + deviceType + "\n" + "OOO \"A-MED\" " + "https://amed-rus.com/"
        infoAboutAppLabel.text = infoAboutAppText
    }
    
    func settingsViews(){
        //  настройка statusBar
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(named: "accentColor")
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }

}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
