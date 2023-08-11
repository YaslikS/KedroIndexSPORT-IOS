import Foundation
import UIKit
import CoreData


class CoreDataManager {
    
    let TAG = "CoreDataManager: "
    
    // MARK: сохранить пароль
    func savePass(pass: String) {
        NSLog(TAG + "savePass: entrance")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        // очистка бд
        do {
            try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "UserCD")))
            try context.save()
            NSLog(TAG + "savePass: clear table success")
        } catch {
            NSLog(TAG + "savePass: clear table error")
        }
        
        // сохранение нового пароля
        let entity = NSEntityDescription.entity(forEntityName: "UserCD", in: context)
        let newUser = UserCD(entity: entity!, insertInto: context)
        newUser.pass = pass
        do{
            try context.save()
            NSLog(TAG + "savePass: user save success")
        }catch{
            NSLog(TAG + "savePass: user save error")
        }
        NSLog(TAG + "savePass: exit")
    }
    
    // MARK: получить пароль
    func getPass() -> String? {
        NSLog(TAG + "getPass: entrance")
        var pass: String?
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCD")
        NSLog(TAG + "getPass: before do")
        do{
            let results: NSArray = try context.fetch(request) as NSArray
            if results.count > 0 {
                let user = results[0] as! UserCD
                pass = user.pass!
                NSLog(TAG + "getPass: clear table success")
            }
        }catch{
            NSLog(TAG + "getPass: Fetch Failed")
            pass = nil
        }
        
        NSLog(TAG + "getPass: exit")
        return pass
    }
    
    // MARK: очистка БД
    func deletePass(){
        NSLog(TAG + "deletePass: entrance")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        do {
            try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "UserCD")))
            try context.save()
            NSLog(TAG + "deletePass: clear table success")
        } catch {
            NSLog(TAG + "deletePass: clear table error")
        }
        NSLog(TAG + "deletePass: exit")
    }
    
}
