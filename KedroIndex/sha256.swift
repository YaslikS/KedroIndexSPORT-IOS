import Foundation
import CryptoKit

func sha256(_ str: String) -> String{
    let inputData = Data(str.utf8)
    let hashed = SHA256.hash(data: inputData)
    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
    NSLog("sha256: hashString:" + hashString)
    return hashString
}
