import UIKit
import Charts

// TODO: вынести работу с БД в отдельный файл
class MainViewController: UIViewController, ChartViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate {
    
    //  объекты view-элементов
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var uploadButton: UIBarButtonItem!
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
    @IBOutlet weak var resultUploadView: UIView!
    @IBOutlet weak var resultUploadLabel: UILabel!
    
    
    var dataForChartsMeasure = NSArray()
    var dataForChartsMeasure2 = NSArray()
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
    var emailJob = EmailJob()
    var storageYourEmailData = StorageYourEmailData()
    var googleSignIn = GoogleSignInJob()
    let coreDataManage = CoreDataManage()
    
    // MARK: при запуске экрана...
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("MainViewCon: viewDidLoad: entrance")

        settingsViews()         //  ...настройка view и ...
        getDataWithCoreData()   //  ...получение данных из БД и заполнение графиков
        NotificationCenter.default.addObserver(self, selector: #selector(appDidUnfolded), name: UIApplication.willEnterForegroundNotification, object: nil)

        NSLog("MainViewCon: viewDidLoad: exit")
    }
    
    // MARK: разворачивание приложения
    @objc func appDidUnfolded(_ application: UIApplication) {
        NSLog("MainViewCon: appDidUnfolded: entrance")
        googleSignIn.ReAuthentication()
        NSLog("MainViewCon: appDidUnfolded: exit")
    }
    
    // MARK: отображение экрана
    override func viewDidAppear(_ animated: Bool) {
        NSLog("MainViewCon: viewDidAppear: entrance")
        
        googleSignIn.ReAuthentication()
        Task {
            NSLog("MainViewCon: viewDidAppear: Task")
            await checkingReachabilityAndStateEmailTrainer()
        }
        NSLog("MainViewCon: viewWillAppear: exit")
    }
    
    // MARK: состояние интернета и почты тренера
    // наблюдение за ним
    func checkingReachabilityAndStateEmailTrainer() async{
        NSLog("MainViewCon: checkingReachabilityAndStateEmailTrainer: entrance")
        if uploadButton != nil {
            while (true){
                switch storageYourEmailData.getStateInternet(){
                case 1:
                    if self.storageYourEmailData.getStateLogin() && self.storageYourEmailData.getStateTrainerEmailAddress(){
                        uploadButton.isEnabled = true
                    } else {
                        uploadButton.isEnabled = false
                    }
                case 0:
                    uploadButton.isEnabled = false
                default:
                    uploadButton.isEnabled = false
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
    
    // MARK: нажатие на кнопку загрузки
    @IBAction func uploadButtonClicked(_ sender: Any) {
        NSLog("MainViewCon: uploadButtonClicked: entrance")
        
        NSLog("MainViewCon: uploadButtonClicked: dataForChartsMeasure.count = " + String(dataForChartsMeasure.count))
        if dataForChartsMeasure.count != 0 {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            let barButton = UIBarButtonItem(customView: activityIndicator)
            navigationItem.setLeftBarButton(barButton, animated: true)
            activityIndicator.startAnimating()

            let emailBody = createJSONforMessage(dataForChartsMeasure, dataForChartsMeasure2)
            emailJob.sendMessage(emailBody: emailBody, using: uploadCompletionHandler)
        } else {
            uploadCompletionHandler(3)
        }
        
        NSLog("MainViewCon: uploadButtonClicked: exit")
    }
    
    // MARK: результат загрузки
    lazy var uploadCompletionHandler: (Int) -> Void = { doneWorking in
        NSLog("MainViewCon: uploadCompletionHandler: entrance")
        switch doneWorking {
        case 1:
            NSLog("MainViewCon: uploadCompletionHandler: doneWorking = 1")
            self.displaySuccessfulDownload()
        case 2:
            NSLog("MainViewCon: uploadCompletionHandler: doneWorking = 2")
            self.displayFailedDownload(errorTxt: NSLocalizedString("resultUploadLabelErrorSendingData", comment: ""))
        case 3:
            NSLog("MainViewCon: uploadCompletionHandler: doneWorking = 3")
            self.displayFailedDownload(errorTxt: NSLocalizedString("resultUploadLabelErrorNoDataToSend", comment: ""))
        default:
            NSLog("MainViewCon: uploadCompletionHandler: doneWorking = " + String(doneWorking))
            self.displayFailedDownload(errorTxt: NSLocalizedString("resultUploadLabelErrorUnknown", comment: ""))
        }
        self.displayStartState()
        NSLog("MainViewCon: uploadCompletionHandler: exit")
    }
    
    func displaySuccessfulDownload(){
        NSLog("MainViewCon: displaySuccessfulDownload")
        navigationItem.setLeftBarButton(uploadButton, animated: true)
        uploadButton.isEnabled = true
        resultUploadView.backgroundColor = UIColor(named: "greenColor")
        settingStatusBar(nameColor: "greenColor")
        resultUploadLabel.text = NSLocalizedString("resultUploadLabelSuccess", comment: "")
        resultUploadView.isHidden = false
    }
    
    func displayFailedDownload(errorTxt: String){
        NSLog("MainViewCon: displayFailedDownload")
        navigationItem.setLeftBarButton(uploadButton, animated: true)
        uploadButton.isEnabled = true
        resultUploadView.backgroundColor = UIColor(named: "redColor")
        settingStatusBar(nameColor: "redColor")
        resultUploadLabel.text = errorTxt
        resultUploadView.isHidden = false
    }
    
    // MARK: показать начальную шапку
    func displayStartState(){
        NSLog("DetailsViewCon: displayStartState: entrance")
        Task {
            NSLog("DetailsViewCon: displayStartState: Task")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            settingStatusBar(nameColor: "accentColor")
            self.resultUploadView.isHidden = true
            self.navigationItem.setLeftBarButton(uploadButton, animated: true)
        }
        NSLog("DetailsViewCon: displayStartState: exit")
    }
    
    // MARK: сохранение измерения
    func saveMeasure(){
        NSLog("MainViewCon: saveMeasure: entrance")
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
        NSLog("dad1flag:" + String(dad1flag) + " pulse1flag:" + String(pulse1flag) + " dad2flag:" + String(dad2flag) + " pulse2flag:" + String(pulse2flag))
        NSLog("dad1:" + String(dad1) + "pulse1:" + String(pulse1) + "dad2:" + String(dad2) + "pulse2:" + String(pulse2))
        //  проверка на все пустые textField
        if dad1flag == true && dad2flag == true && pulse1flag == true && pulse2flag == true {
            NSLog("MainViewCon: saveMeasure: all flag true")
            coreDataManage.saveMeasures(index1: index1, dad1: dad1, pulse1: pulse1, index2: index2, dad2: dad2, pulse2: pulse2)
            getDataWithCoreData()   //  обновляем данные на графиках
            if (isDad1Pulse1Empty){
                dad1flag = false
                pulse1flag = false
            }
            if (isDad2Pulse2Empty){
                dad2flag = false
                pulse2flag = false
            }
        }
        NSLog("MainViewCon: saveMeasure: exit")
    }

    // MARK: нажатие на кнопку сохранения
    @IBAction func clickSaveButton(_ sender: Any) {
        NSLog("MainViewCon: clickSaveButton: entrance")
        //  вывод alertDialog
        let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToKeepTheMeasurement", comment: ""), message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: NSLocalizedString("SaveInAlertDialog", comment: ""), style: .default) { [weak self] (_) in
            NSLog("MainViewCon: clickSaveButton: saveAction: entrance")
            self!.saveMeasure() //  сохранение измерения
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelInAlertDialog", comment: ""), style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        //  для ipad'ов
        if let popover = alert.popoverPresentationController{
            NSLog("MainViewCon: clickSaveButton: popoverPresentationController: for ipad's")
            popover.sourceView = saveMeasureButton
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: нажатие на кнопку очистки
    @IBAction func clickClearButton(_ sender: Any) {
        NSLog("MainViewCon: clickClearButton: entrance")
        //  вывод alertDialog
        let alert = UIAlertController(title: NSLocalizedString("areYouSureYouWantToClearTheCharts", comment: ""), message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("ClearInAlertDialog", comment: ""), style: .destructive) { [weak self] (_) in
            NSLog("MainViewCon: clickClearButton: delateAction: entrance")
            self!.deleteAll()   //  очистка графика и данных из бд
            self!.infoMeasuringView.isHidden = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        //  для ipad'ов
        if let popover = alert.popoverPresentationController{
            NSLog("MainViewCon: clickClearButton: popoverPresentationController: for ipad's")
            popover.sourceView = clearAllButton
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: очистка графика и данных из бд
    func deleteAll(){
        coreDataManage.deleteAll()
        getDataWithCoreData()       //  обновление данных на экране
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
        NSLog("MainViewCon: installInfoAboutKerdo1: index1:" + String(index1))
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
        NSLog("MainViewCon: installInfoAboutKerdo2: index2:" + String(index2))
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
        NSLog("MainViewCon: calcKerdoIndexValue: DAD:" + String(DAD) + " Pulse:" + String(Pulse))
        if (numIndex) {
            index1 = 100 * (1 - DAD / Pulse)
            index1 = Double(String(NSString(format: "%.2f",index1)))!
            NSLog("MainViewCon: calcKerdoIndexValue: index1:" + String(index1))
        } else {
            index2 = 100 * (1 - DAD / Pulse)
            index2 = Double(String(NSString(format: "%.2f",index2)))!
            NSLog("MainViewCon: calcKerdoIndexValue: index2:" + String(index2))
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
        NSLog("MainViewCon: settingsViews: entrance")
        settingStatusBar(nameColor: "accentColor")
        
        //  сглаживание углов
        self.view.bringSubviewToFront(resultUploadView)
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
            NSLog("MainViewCon: settingsViews: for ipad")
            backToAddBottomButton.isHidden = true
        }
        
        NSLog("MainViewCon: settingsViews: exit")
    }
    
    // MARK: лог полученных данных из бд
    func printDataEntrys(){
        NSLog("MainViewCon: printDataEntrys: entrance")
        NSLog("MainViewCon: printDataEntrys: dataForChartsMeasure {")
        for result in dataForChartsMeasure {
            let measure = result as! Measure
            let str = "Measure " + String(measure.id) + " / " + String(measure.kerdoIndex) + " / " + String(measure.dad) + " / " + String(measure.pulse)
            NSLog(str)
        }
        NSLog("MainViewCon: printDataEntrys: dataForChartsMeasure }")
        NSLog("MainViewCon: printDataEntrys: dataForChartsMeasure2 {")
        for result in dataForChartsMeasure2 {
            let measure = result as! Measure2
            let str = "Measure2 " + String(measure.id) + " / " + String(measure.kerdoIndex) + " / " + String(measure.dad) + " / " + String(measure.pulse)
            NSLog(str)
        }
        NSLog("MainViewCon: printDataEntrys: dataForChartsMeasure2 }")
        NSLog("MainViewCon: printDataEntrys: exit")
    }
    
    // MARK: данные из БД и заполнение графиков
    func getDataWithCoreData(){
        NSLog("MainViewCon: getDataWithCoreData: entrance")
        coreDataManage.getMeasuresFromCoreData()
        dataForChartsMeasure = coreDataManage.dataForChartsMeasure
        dataForChartsMeasure2 = coreDataManage.dataForChartsMeasure2
        
        infoMeasuringView.isHidden = true
        printDataEntrys()   // лог полученный данных из бд
        createKedroChart()  // график кедро
        createPulseChart()  // график пульса
        createDadChart()    // график ДАД
        
        NSLog("MainViewCon: getDataWithCoreData: exit")
    }
    
    // MARK: скрытие панели информации о измерении
    @IBAction func clickCloseInfoMeasuring(_ sender: Any) {
        NSLog("MainViewCon: clickCloseInfoMeasuring: entrance")
        infoMeasuringView.isHidden = true
    }
    
    // MARK: нажатие на столбец
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("MainViewCon: chartValueSelected: entrance")
        //  получение данных, которые будут выведены
        let entry1 = dataForChartsMeasure[Int(entry.x) - 1] as! Measure
        let entry2 = dataForChartsMeasure2[Int(entry.x) - 1] as! Measure2
        firstMeasuringInfoLabel.text = String(entry1.kerdoIndex)
        secondMeasuringInfoLabel.text = String(entry2.kerdoIndex)
        dateTimeMeasuringInfoLabel.text = entry1.date
        //  лог
        NSLog("column: " + String(entry.x))
        NSLog("kerdoIndex1: " + String(entry1.kerdoIndex))
        NSLog("kerdoIndex2: " + String(entry2.kerdoIndex))
        NSLog("date: " + entry1.date!)
        
        if entry1.kerdoIndex < -15{
            firstMeasuringInfoView.backgroundColor = UIColor(named: "greenColor")
        } else if 15 < entry1.kerdoIndex {
            firstMeasuringInfoView.backgroundColor = UIColor(named: "redColor")
        } else {
            firstMeasuringInfoView.backgroundColor = UIColor(named: "yellowColor")
        }
        
        if entry2.kerdoIndex < -15{
            secondMeasuringInfoView.backgroundColor = UIColor(named: "greenColor")
        } else if 15 < entry2.kerdoIndex {
            secondMeasuringInfoView.backgroundColor = UIColor(named: "redColor")
        } else {
            secondMeasuringInfoView.backgroundColor = UIColor(named: "yellowColor")
        }
        
        infoMeasuringView.isHidden = false
        NSLog("MainViewCon: chartValueSelected: exit")
    }
    
    // MARK: заполнение графика кедро
    func createKedroChart(){
        NSLog("MainViewCon: createKedroChart: entrance")
        //  заполнение массива с данными для графика
        var entriesKedroChart = [BarChartDataEntry]()
        for index in 0..<dataForChartsMeasure.count {
            let measure = dataForChartsMeasure[index] as! Measure
            entriesKedroChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.kerdoIndex)
                )
            )
            let measure2 = dataForChartsMeasure2[index] as! Measure2
            entriesKedroChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.kerdoIndex)
                )
            )
        }
        NSLog("MainViewCon: createKedroChart: entriesKedroChart filled")
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
        NSLog("MainViewCon: createKedroChart: collors filled")
        //  настройка данных графика
        let set = BarChartDataSet(entries: entriesKedroChart)
        set.valueFont = UIFont(name: "Verdana", size: 12.0)!
        set.colors = colors
        //  настройка отображения графика
        let data = BarChartData(dataSet: set)
        barKedroChart.data = data
        barKedroChart.dragYEnabled = false
        barKedroChart.legend.enabled = false
        barKedroChart.doubleTapToZoomEnabled = false
        barKedroChart.xAxis.granularityEnabled = true
        barKedroChart.xAxis.granularity = 1.0
        barKedroChart.barData?.barWidth = 0.5
        if dataForChartsMeasure.count != 0 {
            barKedroChart.moveViewToX(Double(dataForChartsMeasure.count))
            barKedroChart.setVisibleXRangeMaximum(12)
        }
        NSLog("MainViewCon: createKedroChart: exit")
    }
    
    // MARK: заполнение графика пульса
    func createPulseChart(){
        NSLog("MainViewCon: createPulseChart: entrance")
        //  заполнение массива с данными для графика
        var entriesPulseChart = [BarChartDataEntry]()
        for index in 0..<dataForChartsMeasure.count {
            let measure = dataForChartsMeasure[index] as! Measure
            entriesPulseChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.pulse)
                )
            )
            let measure2 = dataForChartsMeasure2[index] as! Measure2
            entriesPulseChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.pulse)
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
        if dataForChartsMeasure.count != 0 {
            barPulseChart.moveViewToX(Double(dataForChartsMeasure.count))
            barPulseChart.setVisibleXRangeMaximum(12)
        }
        NSLog("MainViewCon: createPulseChart: exit")
    }
    
    // MARK: заполнение графика дад
    func createDadChart(){
        NSLog("MainViewCon: createDadChart: entrance")
        //  заполнение массива с данными для графика
        var entriesDadChart = [BarChartDataEntry]()
        for index in 0..<dataForChartsMeasure.count {
            let measure = dataForChartsMeasure[index] as! Measure
            entriesDadChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure.dad)
                )
            )
            let measure2 = dataForChartsMeasure2[index] as! Measure2
            entriesDadChart.append(
                BarChartDataEntry(
                    x: Double(index + 1),
                    y: Double(measure2.dad)
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
        if dataForChartsMeasure.count != 0 {
            barDadChart.moveViewToX(Double(dataForChartsMeasure.count))
            barDadChart.setVisibleXRangeMaximum(12)
        }
        NSLog("MainViewCon: createDadChart: exit")
    }

    // MARK: Возврат к нижнему view добавления нового измерения
    @IBAction func backToAddBottom(_ sender: Any) {
        NSLog("MainViewCon: backToAddBottom: entrance")
        if idDevice != .pad {
            NSLog("MainViewCon: backToAddBottom: not for ipad")
            bottomScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Переход к информационному нижнему view
    @IBAction func goToInfoBottom(_ sender: Any) {
        NSLog("MainViewCon: goToInfoBottom: entrance")
        if idDevice != .pad {
            NSLog("MainViewCon: goToInfoBottom: not for ipad")
            bottomScrollView.setContentOffset(CGPoint(x: 365, y: 0), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        NSLog("MainViewCon: prepare: entrance")
        // при переходе устанавливается кнопка uploadButton, чтобы она не была nil
        navigationItem.setLeftBarButton(uploadButton, animated: true)
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
