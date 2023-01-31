import Foundation
import Reachability

class ReachabilityJob {
    
    let reachability = try! Reachability()
    var storageYourEmailData = StorageYourEmailData()
    
    // MARK: старт отслеживания интернета
    func startReachability(){
        NSLog("ReachabilityJob: startReachability: entrance")

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("ReachabilityJob: startReachability: Reachable via WiFi")
                self.storageYourEmailData.saveStateInternet(state: 1)
            } else {
                print("ReachabilityJob: startReachability: Reachable via Cellular")
                self.storageYourEmailData.saveStateInternet(state: 1)
            }
        }
        reachability.whenUnreachable = { _ in
            print("ReachabilityJob: startReachability: Not reachable")
            self.storageYourEmailData.saveStateInternet(state: 0)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("ReachabilityJob: startReachability: Unable to start notifier")
            self.storageYourEmailData.saveStateInternet(state: 3)
        }
        NSLog("ReachabilityJob: startReachability: exit")
    }
    
}

