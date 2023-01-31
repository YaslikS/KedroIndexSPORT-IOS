import Foundation

class EmailJob {
    
    var storageYourEmailData = StorageYourEmailData()
    var imapSession = MCOIMAPSession()
    var smtpSession = MCOSMTPSession()
    var idMessage = UInt()
    // пароли для тестов: 9ABpbyp65WxKAY79:
    
    // MARK: отправка email
    func sendMessage(emailBody: String, using completionHandler: @escaping (Int) -> Void){
        NSLog("EmailJob: sendMessage: entrance")
        let smtpSession = self.createSMTPSession()
        let messageBuilder = self.createMessage(emailBody: emailBody)
        sendSMTPMessage(and: messageBuilder!, using: completionHandler)
    }
    
    // MARK: создание SMTP-сессии
    func createSMTPSession() -> MCOSMTPSession {
        NSLog("EmailJob: createSMTPSession: entrance")
        let accessToken = storageYourEmailData.getAccessToken()
        let emailAddress = storageYourEmailData.getYourEmailAddress()
        NSLog("EmailJob: createSMTPSession: emailAddress = " + emailAddress)
        NSLog("EmailJob: createSMTPSession: accessToken = " + accessToken)
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.port = 465
        smtpSession.username = emailAddress
        smtpSession.password = nil
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.oAuth2Token = accessToken
        smtpSession.authType = MCOAuthType.xoAuth2
        smtpSession.timeout = 60
        NSLog("EmailJob: createSMTPSession: exit")
        return smtpSession
    }
    
    // MARK: создание email
    private func createMessage(emailBody: String) -> MCOMessageBuilder? {
        NSLog("EmailJob: createMessage: entrance")
        let fullName = storageYourEmailData.getFullName()
        let emailAddress = storageYourEmailData.getYourEmailAddress()
        let toEmail = storageYourEmailData.getTrainerEmailAddress()
        
        NSLog("EmailJob: createMessage: fullName = " + fullName)
        NSLog("EmailJob: createMessage: emailAddress = " + emailAddress)
        NSLog("EmailJob: createMessage: toEmail = " + toEmail)
        NSLog("EmailJob: createMessage: emailBody = {{{ \n" + emailBody + "\n}}}")
        
        let builder = MCOMessageBuilder()
        builder.header.from = MCOAddress(displayName: fullName, mailbox: emailAddress)
        builder.header.to = [MCOAddress(mailbox: toEmail) ?? ""]
        builder.header.subject = "KerdoIndex Data"
        builder.htmlBody = emailBody
        NSLog("EmailJob: createMessage: exit")
        return builder
    }
    
    // MARK: отправка SMTP-email
    private func sendSMTPMessage(and builder: MCOMessageBuilder, using completionHandler: @escaping (Int) -> Void){
        NSLog("EmailJob: sendSMTPMessage: exit")
        smtpSession.connectionLogger = {(connectionID, type, data) in
            print("EmailJob: sendSMTPMessage: DEBUG PRINT: = ", connectionID!)
            print("EmailJob: sendSMTPMessage: DEBUG PRINT: = ", type)
            //print("EmailJob: sendSMTPMessage: DEBUG PRINT: = ", data!)
            if data != nil {
                print("EmailJob: sendSMTPMessage: DEBUG PRINT: = ", data!)
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("EmailJob: sendSMTPMessage: Connectionlogger: \(string)")
                }
            }
        }
        let builderData = builder.data()
        smtpSession.sendOperation(with: builderData).start { error in
            if (error != nil) {
                NSLog("EmailJob: sendSMTPMessage: Error sending email: {{{\n \(error) \n}}}")
                //self.storageYourEmailData.saveStateUpload(state: 2)
                completionHandler(2)
            } else {
                NSLog("EmailJob: sendSMTPMessage: Successfully sent email!")
                //self.storageYourEmailData.saveStateUpload(state: 1)
                completionHandler(1)
            }
        }
        NSLog("EmailJob: sendSMTPMessage: exit")
    }
    
}
