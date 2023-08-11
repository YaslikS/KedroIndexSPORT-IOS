import UIKit
import Charts

class MainViewController: UIViewController, ChartViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate {
    
    // MARK: объекты view-элементов
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var backToAddBottomButton: UIButton!
    @IBOutlet weak var kedroView: UIView!
    @IBOutlet weak var pulseView: UIView!
    @IBOutlet weak var dadView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var infoBottomView: UIView!
    @IBOutlet weak var addBottomView: UIView!
    @IBOutlet weak var infoKedro1Label: UILabel!
    @IBOutlet weak var infoKedro2Label: UILabel!
    @IBOutlet weak var dad1TextField: UITextField!
    @IBOutlet weak var pulse1TextField: UITextField!
    @IBOutlet weak var kedroIndex1Button: UIButton!
    @IBOutlet weak var dad2TextField: UITextField!
    @IBOutlet weak var pulse2TextField: UITextField!
    @IBOutlet weak var kedroIndex2Button: UIButton!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var saveMeasureButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var infoMeasuringView: UIView!
    @IBOutlet weak var firstMeasuringInfoView: UIView!
    @IBOutlet weak var firstMeasuringInfoLabel: UILabel!
    @IBOutlet weak var secondMeasuringInfoView: UIView!
    @IBOutlet weak var secondMeasuringInfoLabel: UILabel!
    @IBOutlet weak var dateTimeMeasuringInfoLabel: UILabel!
    @IBOutlet weak var kedroViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pulseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dadViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var jsonIsEmptyView: UIView!
    @IBOutlet weak var offlneModeInfoButton: UIButton!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    
    // MARK: переменные
    var measures1: [MeasureNew] = []
    var measures2: [MeasureNew] = []
    var barKedroChart = BarChartView()
    var barPulseChart = BarChartView()
    var barDadChart = BarChartView()
    var idDevice = UIScreen.main.traitCollection.userInterfaceIdiom
    var index1 = Double()
    var index2 = Double()
    var dad1 = Double()
    var dad2 = Double()
    var pulse1 = Double()
    var pulse2 = Double()
    var dad1flag = false
    var dad2flag = false
    var pulse1flag = false
    var pulse2flag = false
    var userDefaultsManager = UserDefaultsManager()
    var fireBaseAuthManager = FireBaseAuthManager()
    var fireBaseCloudManager = FireBaseCloudManager()
    var coreDataManager = CoreDataManager()
    let TAG = "MainViewController: "
    
    
    // MARK: при запуске экрана...
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog(TAG + "viewDidLoad: entrance")
        
        settingsViews() //  ...настройка view и ...
        gettingJson()   //  ...получение данных и заполнение графиков
        NotificationCenter.default.addObserver(self, selector: #selector(appDidUnfolded), name: UIApplication.willEnterForegroundNotification, object: nil)

        NSLog(TAG + "viewDidLoad: exit")
    }

    
    // MARK: разворачивание приложения
    @objc func appDidUnfolded(_ application: UIApplication) {
        NSLog(TAG + "appDidUnfolded: entrance")
        
        tryAuth()
        
        NSLog(TAG + "appDidUnfolded: exit")
    }
    
    // MARK: попытка авторизации
    func tryAuth(){
        NSLog(TAG + "tryAuth: entrance")
        fireBaseAuthManager.reAuth(using: reAuthCompletionHandler)
        NSLog(TAG + "tryAuth: exit")
    }
        
    // MARK: результат ре-авторизации
    lazy var reAuthCompletionHandler: (Int, String) -> Void = { doneWorking, desc in
        NSLog(self.TAG + "reAuthCompletionHandler: entrance")
        switch doneWorking {
        case 0: //  удачный вход
            NSLog(self.TAG + "reAuthCompletionHandler: doneWorking = 0")
            self.fireBaseCloudManager.getCloudData()
            if (self.userDefaultsManager.getPassword() != "0"
                && self.userDefaultsManager.getPassword() != ""
            ){
                self.coreDataManager.savePass(pass: self.userDefaultsManager.getPassword())
                NSLog(self.TAG + "reAuthCompletionHandler: doneWorking = 0: passCD = " + self.coreDataManager.getPass()!)
            }
        case 4: //  сетевая ошибка
            NSLog(self.TAG + "reAuthCompletionHandler: doneWorking = 4")
            
            self.settingStatusBar(nameColor: "redColor")
            self.navigationBar.title = "You not logged in!"
            Task {
                NSLog(self.TAG + "installNameUser: Task")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                self.settingStatusBar(nameColor: "accentColor")
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                self.navigationBar.title = "KerdoIndexSPORT"
            }
            
            let alert = UIAlertController(title: "Check your internet connection", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "reAuthCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                //popover.sourceView = self.loginButton
            }
            self.present(alert, animated: true, completion: nil)
        default:    //  НЕудачный вход
            NSLog(self.TAG + "reAuthCompletionHandler: doneWorking = " + String(doneWorking))
            
            self.settingStatusBar(nameColor: "redColor")
            self.navigationBar.title = "You not logged in!"
            Task {
                NSLog(self.TAG + "installNameUser: Task")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                self.settingStatusBar(nameColor: "accentColor")
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                self.navigationBar.title = "KerdoIndexSPORT"
            }
            
            let alert = UIAlertController(title: "Unexpected login error. Try login manually", message: nil, preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] (_) in
                NSLog(self!.TAG + "reAuthCompletionHandler: UIAlertController: OK")
            }
            alert.addAction(okAction)
            //  для ipad'ов
            if let popover = alert.popoverPresentationController{
                NSLog(self.TAG + "clickClearButton: popoverPresentationController: for ipad's")
                //popover.sourceView = self.loginButton
            }
            self.present(alert, animated: true, completion: nil)
        }
    
        NSLog(self.TAG + "reAuthCompletionHandler: exit")
    }
    
    // MARK: отображение экрана
    override func viewDidAppear(_ animated: Bool) {
        NSLog(TAG + "viewDidAppear: entrance")
        
        tryAuth()
        Task {
            NSLog(TAG + "viewDidAppear: Task")
            await checkingReachability()
        }
        installNameUser()
        gettingJson()
        
        NSLog(TAG + "viewWillAppear: exit")
    }
    
    // MARK: состояние интернета
    // наблюдение за ним
    func checkingReachability() async{
        NSLog(TAG + "checkingReachability: entrance")
        while (true){
            switch userDefaultsManager.getStateInternet(){
            case 1:
                offlneModeInfoButton.isHidden = true
            case 0:
                offlneModeInfoButton.isHidden = false
            default:
                offlneModeInfoButton.isHidden = false
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
    // MARK: сохранение измерения
    func saveMeasure(){
        NSLog(TAG + "saveMeasure: entrance")
        var isDad1Pulse1Empty = false
        var isDad2Pulse2Empty = false
        //  проверка на пустые textField 1го измерения
        if dad1TextField.text == "" && pulse1TextField.text == "" {
            dad1flag = true
            pulse1flag = true
            dad1 = 0
            pulse1 = 0
            index1 = 0
            isDad1Pulse1Empty = true
        }
        //  проверка на пустые textField 1го измерения
        if dad2TextField.text == "" && pulse2TextField.text == "" {
            dad2flag = true
            pulse2flag = true
            dad2 = 0
            pulse2 = 0
            index2 = 0
            isDad2Pulse2Empty = true
        }
        NSLog("saveMeasure: dad1flag:" + String(dad1flag) + " pulse1flag:" + String(pulse1flag) + " dad2flag:" + String(dad2flag) + " pulse2flag:" + String(pulse2flag))
        NSLog("saveMeasure: dad1:" + String(dad1) + "pulse1:" + String(pulse1) + "dad2:" + String(dad2) + "pulse2:" + String(pulse2))
        //  проверка на все пустые textField
        if dad1flag == true && dad2flag == true && pulse1flag == true && pulse2flag == true {
            NSLog(TAG + "saveMeasure: all flag true")
            let mytime = Date()
            let format = DateFormatter()
            format.dateFormat = "dd.MM.yyyy HH:mm:ss"
            let dateText = format.string(from: mytime)
            
            let newMeasure1 = MeasureNew(id: "", DAD: String(dad1), Pulse: String(pulse1), KerdoIndex: String(index1), number: "", date: dateText, desc: "", f1: "", f2: "", f3: "", f4: "", f5: "")
            let newMeasure2 = MeasureNew(id: "", DAD: String(dad2), Pulse: String(pulse2), KerdoIndex: String(index2), number: "", date: dateText, desc: "", f1: "", f2: "", f3: "", f4: "", f5: "")
            measures1.append(newMeasure1)
            measures2.append(newMeasure2)
            let json = createJson(kerdo1Mas: measures1, kerdo2Mas: measures2)
            userDefaultsManager.saveJson(json: json)
            userDefaultsManager.saveLastDate(lastDate: dateText)
            if fireBaseAuthManager.stateAuth(){
                fireBaseCloudManager.updateLastDateInCloudData()
                fireBaseCloudManager.updateJsonInCloudData()
            }
            
            clearGraths()
            gettingJson()
            if (isDad1Pulse1Empty){
                dad1flag = false
                pulse1flag = false
            }
            if (isDad2Pulse2Empty){
                dad2flag = false
                pulse2flag = false
            }
        }
        NSLog(TAG + "saveMeasure: exit")
    }
    
    // MARK: получение json с измерениями
    func gettingJson(){
        NSLog(TAG + "gettingJson: entrance")
        let json = userDefaultsManager.getJson()
        if (json != "empty" && json != ""){
            NSLog(TAG + "gettingJson: json != empty")
            jsonIsNotEmpty()
            let js = parcingJson(json: json)
            measures1 = js!.measures1
            measures2 = js!.measures2
            createGraths()
        } else {
            jsonIsEmpty()
            NSLog(TAG + "gettingJson: json == empty")
        }
        NSLog(TAG + "gettingJson: exit")
    }
    
    // MARK: json НЕ пустой
    func jsonIsNotEmpty(){
        NSLog(TAG + "jsonIsNotEmpty: entrance")
        kedroViewHeight.constant = 300
        dadViewHeight.constant = 300
        pulseViewHeight.constant = 300
        mainViewHeight.constant = 1300
        jsonIsEmptyView.isHidden = true
    }
    
    // MARK: если json пустой
    func jsonIsEmpty(){
        NSLog(TAG + "jsonIsEmpty: entrance")
        kedroViewHeight.constant = 1
        dadViewHeight.constant = 1
        pulseViewHeight.constant = 1
        mainViewHeight.constant = 300
        jsonIsEmptyView.isHidden = false
    }
    
    // MARK: создание и настройка графов
    func createGraths(){
        NSLog(TAG + "createGraths: entrance")
        infoMeasuringView.isHidden = true
        if (!measures1.isEmpty && !measures2.isEmpty){
            NSLog(TAG + "createGraths: !measures1.isEmpty && !measures2.isEmpty")
            printDataEntrys()   // лог полученный данных из бд
            createKedroChart()  // график кедро
            createPulseChart()  // график пульса
            createDadChart()    // график ДАД
        } else {
            NSLog(TAG + "createGraths: error: DB is empty")
        }        
        NSLog(TAG + "createGraths: exit")
    }
    
    // MARK: очистка графов
    func clearGraths(){
        NSLog(TAG + "clearGraths: entrance")
        barKedroChart.clear()
        barDadChart.clear()
        barPulseChart.clear()
    }

    // MARK: нажатие на кнопку сохранения
    @IBAction func clickSaveButton(_ sender: Any) {
        NSLog(TAG + "clickSaveButton: entrance")
        //  вывод alertDialog
        let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToKeepTheMeasurement", comment: ""), message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: NSLocalizedString("SaveInAlertDialog", comment: ""), style: .default) { [weak self] (_) in
            NSLog(self!.TAG + "clickSaveButton: saveAction: entrance")
            self!.saveMeasure() //  сохранение измерения
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelInAlertDialog", comment: ""), style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        //  для ipad'ов
        if let popover = alert.popoverPresentationController{
            NSLog(TAG + "clickSaveButton: popoverPresentationController: for ipad's")
            popover.sourceView = saveMeasureButton
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: нажатие на кнопку очистки
    @IBAction func clickClearButton(_ sender: Any) {
        NSLog(TAG + "clickClearButton: entrance")
        //  вывод alertDialog
        let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToClearTheCharts", comment: ""), message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("ClearInAlertDialog", comment: ""), style: .destructive) { [weak self] (_) in
            NSLog(self!.TAG + "clickClearButton: delateAction: entrance")
            self!.measures1.removeAll()
            self!.measures2.removeAll()
            self!.userDefaultsManager.saveJson(json: "empty")
            self!.userDefaultsManager.saveLastDate(lastDate: "")
            self!.clearGraths()
            self!.jsonIsEmpty()
            self!.infoMeasuringView.isHidden = true
            if self!.fireBaseAuthManager.stateAuth(){
                NSLog(self!.TAG + "clickClearButton: delateAction: stateAuth == true")
                self!.fireBaseCloudManager.updateJsonInCloudData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        //  для ipad'ов
        if let popover = alert.popoverPresentationController{
            NSLog(TAG + "clickClearButton: popoverPresentationController: for ipad's")
            popover.sourceView = clearAllButton
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: changed textField DAD 1
    @IBAction func dad1TFchanged(_ sender: Any) {
        var dad1 : Double?
        dad1 = Double(dad1TextField.text!)
        guard dad1 != nil else {
            dad1TextField.text = ""
            return
        }
        if dad1 != nil && dad1! >= 30 && dad1! <= 130 {
            dad1TextField.backgroundColor = UIColor(named: "Default")
            dad1flag = true
            self.dad1 = dad1!
            if pulse1flag == true {
                calcKerdoIndexValue(numIndex: true, DAD: dad1!, Pulse: pulse1)
                kedroIndex1Button.setTitle(String(NSString(format: "%.2f",index1)), for: .normal)
                kedroIndex1Button.isHidden = false
                saveMeasureButton.isHidden = false
                installInfoAboutKerdo1()
            }
        }else{
            dad1TextField.backgroundColor = UIColor(named: "redColor")
            dad1flag = false
            saveMeasureButton.isHidden = true
            kedroIndex1Button.isHidden = true
            infoKedro1Label.text = NSLocalizedString("infoKedro1LabelincorrectIndex1", comment: "")
        }
    }
    
    // MARK: changed textField pulse 1
    @IBAction func pulse1TFchanged(_ sender: Any) {
        var pulse1 : Double?
        pulse1 = Double(pulse1TextField.text!)
        guard pulse1 != nil else {
            pulse1TextField.text = ""
            return
        }
        if pulse1 != nil && pulse1! >= 40 && pulse1! <= 230 {
            pulse1TextField.backgroundColor = UIColor(named: "Default")
            pulse1flag = true
            self.pulse1 = pulse1!
            if dad1flag == true {
                calcKerdoIndexValue(numIndex: true, DAD: dad1, Pulse: pulse1!)
                kedroIndex1Button.setTitle(String(NSString(format: "%.2f",index1)), for: .normal)
                kedroIndex1Button.isHidden = false
                saveMeasureButton.isHidden = false
                installInfoAboutKerdo1()
            }
        }else{
            pulse1TextField.backgroundColor = UIColor(named: "redColor")
            pulse1flag = false
            kedroIndex1Button.isHidden = true
            saveMeasureButton.isHidden = true
            infoKedro1Label.text = NSLocalizedString("infoKedro1LabelincorrectIndex1", comment: "")
        }
    }
    
    // MARK: changed textField DAD 2
    @IBAction func dad2TFchanged(_ sender: Any) {
        var dad2 : Double?
        dad2 = Double(dad2TextField.text!)
        guard dad2 != nil else {
            dad2TextField.text = ""
            return
        }
        if dad2 != nil && dad2! >= 30 && dad2! <= 130 {
            dad2TextField.backgroundColor = UIColor(named: "Default")
            dad2flag = true
            self.dad2 = dad2!
            if pulse2flag == true {
                calcKerdoIndexValue(numIndex: false, DAD: dad2!, Pulse: pulse2)
                kedroIndex2Button.setTitle(String(NSString(format: "%.2f",index2)), for: .normal)
                kedroIndex2Button.isHidden = false
                saveMeasureButton.isHidden = false
                installInfoAboutKerdo2()
            }
        }else{
            dad2TextField.backgroundColor = UIColor(named: "redColor")
            dad2flag = false
            kedroIndex2Button.isHidden = true
            saveMeasureButton.isHidden = true
            infoKedro2Label.text = NSLocalizedString("infoKedro1LabelincorrectIndex2", comment: "")
        }
    }
    
    // MARK: changed textField pulse 2
    @IBAction func pulse2TFchanged(_ sender: Any) {
        var pulse2 : Double?
        pulse2 = Double(pulse2TextField.text!)
        guard pulse2 != nil else {
            pulse2TextField.text = ""
            return
        }
        if pulse2 != nil && pulse2! >= 40 && pulse2! <= 230 {
            pulse2TextField.backgroundColor = UIColor(named: "Default")
            pulse2flag = true
            self.pulse2 = pulse2!
            if dad2flag == true {
                calcKerdoIndexValue(numIndex: false, DAD: dad2, Pulse: pulse2!)
                kedroIndex2Button.setTitle(String(NSString(format: "%.2f",index2)), for: .normal)
                kedroIndex2Button.isHidden = false
                saveMeasureButton.isHidden = false
                installInfoAboutKerdo2()
            }
        }else{
            pulse2TextField.backgroundColor = UIColor(named: "redColor")
            pulse2flag = false
            kedroIndex2Button.isHidden = true
            saveMeasureButton.isHidden = true
            infoKedro2Label.text = NSLocalizedString("infoKedro1LabelincorrectIndex2", comment: "")
        }
    }
    
    // MARK: 1ое измерение: установка описания
    func installInfoAboutKerdo1(){
        NSLog(TAG + "installInfoAboutKerdo1: index1:" + String(index1))
        if index1 < -15 {
            infoKedro1Label.text = NSLocalizedString("infoKedro1Labelindex1Less-15", comment: "")
        }
        if index1 < -30{
            infoKedro1Label.text = NSLocalizedString("infoKedro1Labelindex1Less-30", comment: "")
        }
        if 15 < index1 {
            infoKedro1Label.text = NSLocalizedString("infoKedro1Labelindex1Above15", comment: "")
        }
        if 30 < index1 {
            infoKedro1Label.text = NSLocalizedString("infoKedro1Labelindex1Above30", comment: "")
        }
        if -15 <= index1 && index1 <= 15 {
            infoKedro1Label.text = NSLocalizedString("infoKedro1Labelindex1-15to15", comment: "")
        }
    }

    // MARK: 2ое измерение: установка описания
    func installInfoAboutKerdo2(){
        NSLog(TAG + "installInfoAboutKerdo2: index2:" + String(index2))
        if index2 < -15 {
            infoKedro2Label.text = NSLocalizedString("infoKedro1Labelindex2Less-15", comment: "")
        }
        if index2 < -30{
            infoKedro2Label.text = NSLocalizedString("infoKedro1Labelindex2Less-30", comment: "")
        }
        if 15 < index2 {
            infoKedro2Label.text = NSLocalizedString("infoKedro1Labelindex2Above15", comment: "")
        }
        if 30 < index2 {
            infoKedro2Label.text = NSLocalizedString("infoKedro1Labelindex2Above30", comment: "")
        }
        if -15 <= index2 && index2 <= 15 {
            infoKedro2Label.text = NSLocalizedString("infoKedro1Labelindex2-15to15", comment: "")
        }
        
    }
    
    // MARK: считаем индекс
    // numIndex : true - 1ый, false - 2ый
    func calcKerdoIndexValue(numIndex: Bool, DAD: Double, Pulse: Double) {
        NSLog(TAG + "calcKerdoIndexValue: DAD:" + String(DAD) + " Pulse:" + String(Pulse))
        if (numIndex) {
            index1 = 100 * (1 - DAD / Pulse)
            index1 = Double(String(NSString(format: "%.2f",index1)))!
            NSLog(TAG + "calcKerdoIndexValue: index1:" + String(index1))
        } else {
            index2 = 100 * (1 - DAD / Pulse)
            index2 = Double(String(NSString(format: "%.2f",index2)))!
            NSLog(TAG + "calcKerdoIndexValue: index2:" + String(index2))
        }
    }
    
    // MARK: настройка statusBar
    func settingStatusBar(nameColor: String){
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(named: nameColor)
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    // MARK: настройка view
    func settingsViews(){
        NSLog(TAG + "settingsViews: entrance")
        settingStatusBar(nameColor: "accentColor")
        
        //  сглаживание углов
        //self.view.bringSubviewToFront(resultUploadView)
        self.view.bringSubviewToFront(infoMeasuringView)
        infoMeasuringView.layer.cornerRadius = 20
        addBottomView.layer.cornerRadius = 20
        infoBottomView.layer.cornerRadius = 20
        firstMeasuringInfoView.layer.cornerRadius = 10
        secondMeasuringInfoView.layer.cornerRadius = 10
        
        //  настройка графиков
        barKedroChart.delegate = self
        barKedroChart.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.shouldIgnoreScrollingAdjustment = true
        bottomScrollView.shouldIgnoreScrollingAdjustment = true
        
        kedroView.addSubview(barKedroChart)
        let topAnchorKedro = barKedroChart.topAnchor.constraint(equalTo: kedroView.topAnchor, constant: 5)
        let bottomAnchorKedro = barKedroChart.bottomAnchor.constraint(equalTo: kedroView.bottomAnchor, constant: -5)
        let leftAnchorKedro = barKedroChart.leftAnchor.constraint(equalTo: kedroView.leftAnchor, constant: 5)
        let rightAnchorKedro = barKedroChart.rightAnchor.constraint(equalTo: kedroView.rightAnchor, constant: -5)
        NSLayoutConstraint.activate([topAnchorKedro, bottomAnchorKedro, leftAnchorKedro, rightAnchorKedro])
        
        barPulseChart.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        pulseView.addSubview(barPulseChart)
        let topAnchorPulse = barPulseChart.topAnchor.constraint(equalTo: pulseView.topAnchor, constant: 5)
        let bottomAnchorPulse = barPulseChart.bottomAnchor.constraint(equalTo: pulseView.bottomAnchor, constant: -5)
        let leftAnchorPulse = barPulseChart.leftAnchor.constraint(equalTo: pulseView.leftAnchor, constant: 5)
        let rightAnchorPulse = barPulseChart.rightAnchor.constraint(equalTo: pulseView.rightAnchor, constant: -5)
        NSLayoutConstraint.activate([topAnchorPulse, bottomAnchorPulse, leftAnchorPulse, rightAnchorPulse])
        
        barDadChart.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        dadView.addSubview(barDadChart)
        let topAnchorDad = barDadChart.topAnchor.constraint(equalTo: dadView.topAnchor, constant: 5)
        let bottomAnchorDad = barDadChart.bottomAnchor.constraint(equalTo: dadView.bottomAnchor, constant: -5)
        let leftAnchorDad = barDadChart.leftAnchor.constraint(equalTo: dadView.leftAnchor, constant: 5)
        let rightAnchorDad = barDadChart.rightAnchor.constraint(equalTo: dadView.rightAnchor, constant: -5)
        NSLayoutConstraint.activate([topAnchorDad, bottomAnchorDad, leftAnchorDad, rightAnchorDad])
        
        //  проверка устройства
        if idDevice == .pad {
            NSLog(TAG + "settingsViews: for ipad")
            backToAddBottomButton.isHidden = true
        }
        
        NSLog(TAG + "settingsViews: exit")
    }
    
    // MARK: установка имени поль-ля
    func installNameUser(){
        NSLog(TAG + "installNameUser: entrance")
        navigationBar.title = "KerdoIndexSPORT"
        if fireBaseAuthManager.stateAuth() {
            Task {
                NSLog(TAG + "installNameUser: Task")
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                navigationBar.title = userDefaultsManager.getYourName()
            }
        }
    }
    
    // MARK: лог полученных данных из бд
    func printDataEntrys(){
        NSLog(TAG + "printDataEntrys: entrance")
        NSLog(TAG + "printDataEntrys: measures1 {")
        for result in measures1 {
            let str = "Measure " + result.id + " / " + result.KerdoIndex
            + " / " + result.DAD + " / " + result.Pulse
            NSLog(str)
        }
        NSLog(TAG + "printDataEntrys: measures1 }")
        NSLog(TAG + "printDataEntrys: measures2 {")
        for result in measures2 {
            let str = "Measure " + result.id + " / " + result.KerdoIndex
            + " / " + result.DAD + " / " + result.Pulse
            NSLog(str)
        }
        NSLog(TAG + "printDataEntrys: measures2 }")
        NSLog(TAG + "printDataEntrys: exit")
    }
    
    // MARK: скрытие панели информации о измерении
    @IBAction func clickCloseInfoMeasuring(_ sender: Any) {
        NSLog(TAG + "clickCloseInfoMeasuring: entrance")
        infoMeasuringView.isHidden = true
    }
    
    // MARK: нажатие на столбец
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog(TAG + "chartValueSelected: entrance")
        //  получение данных, которые будут выведены
        let entry1 = measures1[Int(entry.x) - 1]
        let entry2 = measures2[Int(entry.x) - 1]
        firstMeasuringInfoLabel.text = entry1.KerdoIndex
        secondMeasuringInfoLabel.text = entry2.KerdoIndex
        dateTimeMeasuringInfoLabel.text = entry1.date
        //  лог
        NSLog("column: " + String(entry.x))
        NSLog("kerdoIndex1: " + entry1.KerdoIndex)
        NSLog("kerdoIndex2: " + entry2.KerdoIndex)
        NSLog("date: " + entry1.date)
        
        if Double(entry1.KerdoIndex)! < -15{
            firstMeasuringInfoView.backgroundColor = UIColor(named: "greenColor")
        } else if 15 < Double(entry1.KerdoIndex)! {
            firstMeasuringInfoView.backgroundColor = UIColor(named: "redColor")
        } else {
            firstMeasuringInfoView.backgroundColor = UIColor(named: "yellowColor")
        }
        
        if Double(entry2.KerdoIndex)! < -15{
            secondMeasuringInfoView.backgroundColor = UIColor(named: "greenColor")
        } else if 15 < Double(entry2.KerdoIndex)! {
            secondMeasuringInfoView.backgroundColor = UIColor(named: "redColor")
        } else {
            secondMeasuringInfoView.backgroundColor = UIColor(named: "yellowColor")
        }
        
        infoMeasuringView.isHidden = false
        NSLog(TAG + "chartValueSelected: exit")
    }
    
    // MARK: заполнение графика кедро
    func createKedroChart(){
        NSLog(TAG + "createKedroChart: entrance")
        //  заполнение массива с данными для графика
        var entriesKedroChart = [BarChartDataEntry]()
        for index in 0..<measures1.count {
            let measure = measures1[index]
            entriesKedroChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.KerdoIndex)!
                )
            )
            let measure2 = measures2[index]
            entriesKedroChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.KerdoIndex)!
                )
            )
        }
        NSLog(TAG + "createKedroChart: entriesKedroChart filled")
        //  заполнение массива с цветами
        var colors = [NSUIColor]()
        for i in entriesKedroChart {
            if i.y < -15{
                colors.append(NSUIColor(cgColor: UIColor(named: "greenColor")!.cgColor))
            } else if 15 < i.y {
                colors.append(NSUIColor(cgColor: UIColor(named: "redColor")!.cgColor))
            } else {
                colors.append(NSUIColor(cgColor: UIColor(named: "yellowColor")!.cgColor))
            }
        }
        NSLog(TAG + "createKedroChart: collors filled")
        //  настройка данных графика
        let set = BarChartDataSet(entries: entriesKedroChart)
        set.valueFont = UIFont(name: "Verdana", size: 12.0)!
        set.colors = colors
        //  настройка отображения графика
        let data = BarChartData(dataSet: set)
        barKedroChart.data = data
        barKedroChart.dragYEnabled = false  //  заблокировать прокрутку по оси y
        barKedroChart.legend.enabled = false//  отключить легенду графика
        barKedroChart.doubleTapToZoomEnabled = false//  включить двойной тап для увеливения
        barKedroChart.xAxis.granularityEnabled = true// включить принудительную детализацию
        barKedroChart.xAxis.granularity = 1.0   //  детализация графика вплоть до целых чисел
        barKedroChart.barData?.barWidth = 0.5   //  ширина столбца
        if measures1.count != 0 {
            barKedroChart.moveViewToX(Double(measures1.count))  //  прокрутка графика до последнего измерения
                barKedroChart.setVisibleXRangeMaximum(12)   // максимальное количество отображаемых измерений
        }
        NSLog(TAG + "createKedroChart: exit")
    }
    
    // MARK: заполнение графика пульса
    func createPulseChart(){
        NSLog(TAG + "createPulseChart: entrance")
        //  заполнение массива с данными для графика
        var entriesPulseChart = [BarChartDataEntry]()
        for index in 0..<measures1.count {
            let measure = measures1[index]
            entriesPulseChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.Pulse)!
                )
            )
            let measure2 = measures2[index]
            entriesPulseChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.Pulse)!
                )
            )
        }
        //  настройка данных графика
        let set = BarChartDataSet(entries: entriesPulseChart)
        set.valueFont = UIFont(name: "Verdana", size: 12.0)!
        //  настройка отображения графика
        set.addColor(NSUIColor(cgColor: UIColor.systemBlue.cgColor))
        let data = BarChartData(dataSet: set)
        barPulseChart.data = data
        barPulseChart.dragYEnabled = false
        barPulseChart.legend.enabled = false
        barPulseChart.isUserInteractionEnabled = false
        barPulseChart.doubleTapToZoomEnabled = false
        barPulseChart.xAxis.granularityEnabled = true
        barPulseChart.xAxis.granularity = 1.0
        barPulseChart.barData?.barWidth = 0.5
        if measures1.count != 0 {
            barPulseChart.moveViewToX(Double(measures1.count))
            barPulseChart.setVisibleXRangeMaximum(12)
        }
        NSLog(TAG + "createPulseChart: exit")
    }
    
    // MARK: заполнение графика дад
    func createDadChart(){
        NSLog(TAG + "createDadChart: entrance")
        //  заполнение массива с данными для графика
        var entriesDadChart = [BarChartDataEntry]()
        for index in 0..<measures1.count {
            let measure = measures1[index]
            entriesDadChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.DAD)!
                )
            )
            let measure2 = measures2[index]
            entriesDadChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.DAD)!
                )
            )
        }
        //  настройка данных графика
        let set = BarChartDataSet(entries: entriesDadChart)
        set.valueFont = UIFont(name: "Verdana", size: 12.0)!
        //  настройка отображения графика
        set.addColor(NSUIColor(cgColor: UIColor.systemBlue.cgColor))
        let data = BarChartData(dataSet: set)
        barDadChart.data = data
        barDadChart.dragYEnabled = false
        barDadChart.legend.enabled = false
        barDadChart.isUserInteractionEnabled = false
        barDadChart.doubleTapToZoomEnabled = false
        barDadChart.xAxis.granularityEnabled = true
        barDadChart.xAxis.granularity = 1.0
        barDadChart.barData?.barWidth = 0.5
        if measures1.count != 0 {
            barDadChart.moveViewToX(Double(measures1.count))
            barDadChart.setVisibleXRangeMaximum(12)
        }
        NSLog(TAG + "createDadChart: exit")
    }

    // MARK: Возврат к нижнему view добавления нового измерения
    @IBAction func backToAddBottom(_ sender: Any) {
        NSLog(TAG + "backToAddBottom: entrance")
        if idDevice != .pad {
            NSLog(TAG + "backToAddBottom: not for ipad")
            bottomScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Переход к информационному нижнему view
    @IBAction func goToInfoBottom(_ sender: Any) {
        NSLog(TAG + "goToInfoBottom: entrance")
        if idDevice != .pad {
            NSLog(TAG + "goToInfoBottom: not for ipad")
            bottomScrollView.setContentOffset(CGPoint(x: 365, y: 0), animated: true)
        }
    }

}

// MARK: округлые столбцы
// Для округлых столбцов в файле BarChartRenderer.swift

//if !isSingleColor
//{
//    // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
//    context.setFillColor(dataSet.color(atIndex: j).cgColor)
//}
//
//context.fill(barRect) <-- это заменить на...
//  ...это:
//let bezierPath = UIBezierPath(roundedRect: barRect, cornerRadius:10)
//context.addPath(bezierPath.cgPath)
//context.drawPath(using: .fill)
//
//if drawBorder
//{
//    context.setStrokeColor(borderColor.cgColor)
//    context.setLineWidth(borderWidth)
//    context.stroke(barRect)
//}
