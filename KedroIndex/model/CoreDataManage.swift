import Foundation
import UIKit
import CoreData

class CoreDataManage {
    
    var dataForChartsMeasure = NSArray()
    var dataForChartsMeasure2 = NSArray()
    
    // MARK: список измерений из БД
    func getMeasuresFromCoreData(){
        NSLog("CoreDataManage: getMeasuresFromCoreData: entrance")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Measure")
        let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Measure2")
        do{
            dataForChartsMeasure = try context.fetch(request) as NSArray
            dataForChartsMeasure2 = try context.fetch(request2) as NSArray
            NSLog("CoreDataManage: getMeasuresFromCoreData: all data getted")
        }catch{
            NSLog("CoreDataManage: getMeasuresFromCoreData: Fetch Failed")
        }
        printDataEntrys()
        NSLog("CoreDataManage: getMeasuresFromCoreData: exit")
    }
    
    // MARK: лог данных из бд
    func printDataEntrys(){
        NSLog("CoreDataManage: printDataEntrys: entrance")
        NSLog("CoreDataManage: printDataEntrys: dataSportsmans {")
        var index = 0
        while index < dataForChartsMeasure.count {
            let measure = dataForChartsMeasure[0] as! Measure
            let measure2 = dataForChartsMeasure2[0] as! Measure2

            let measure1str1 = "measure 1: " + String(measure.kerdoIndex) + " / " + (measure.date ?? "??")
            let measure1str2 = " / " + String(measure.id) + " / "
            let measure1str3 = String(measure.dad) + " / " + String(measure.pulse)
            
            NSLog(measure1str1 + measure1str2 + measure1str3)
            
            let measure2str1 = "measure 2: " + String(measure2.kerdoIndex) + " / " + (measure2.date ?? "??")
            let measure2str2 = " / " + String(measure2.id) + " / "
            let measure2str3 = String(measure2.dad) + " / " + String(measure2.pulse)
            
            NSLog(measure2str1 + measure2str2 + measure2str3)
            index+=1
        }
        NSLog("CoreDataManage: printDataEntrys: dataForChartsMeasure }")
        NSLog("CoreDataManage: printDataEntrys: exit")
    }
    
    // MARK: сохранение измерений в БД
    func saveMeasures(index1: Double, dad1: Double, pulse1: Double,
                      index2: Double, dad2: Double, pulse2: Double
    ){
        //  получение контекста бд
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        //  работа с сущностью бд
        let entity = NSEntityDescription.entity(forEntityName: "Measure", in: context)
        let newMeasure = Measure(entity: entity!, insertInto: context)
        let entity2 = NSEntityDescription.entity(forEntityName: "Measure2", in: context)
        let newMeasure2 = Measure2(entity: entity2!, insertInto: context)
        //  сохранение поля даты
        let mytime = Date()
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy HH:mm:ss"
        newMeasure.date = format.string(from: mytime)
        newMeasure2.date = format.string(from: mytime)
        //  сохранение некоторых полей
        newMeasure.kerdoIndex = index1
        newMeasure.dad = dad1
        newMeasure.pulse = pulse1
        newMeasure2.kerdoIndex = index2
        newMeasure2.dad = dad2
        newMeasure2.pulse = pulse2
        //  сохранение поля id, равное количеству данных в бд
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Measure")
            let results: NSArray = try context.fetch(request) as NSArray
            newMeasure.id = Int32(results.count)
            newMeasure2.id = Int32(results.count)
        } catch {
            NSLog("CoreDataManage: saveMeasures: Fetch Failed")
        }
        do{
            try context.save()
            NSLog("CoreDataManage: saveMeasures: all OK")
        }catch{
            NSLog("CoreDataManage: saveMeasures: context save error")
        }
    }
    
    // MARK: очистка графика и данных из бд
    func deleteAll(){
        NSLog("MainViewCon: delateAll: entrance")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Measure")
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Measure2")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        do {
            try context.execute(deleteRequest)
            try context.execute(deleteRequest2)
            NSLog("CoreDataManage: deleteAll: context.execute")
        } catch _ as NSError {
            NSLog("CoreDataManage: deleteAll: Fetch Failed")
        }
    }
}
