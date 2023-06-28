import Foundation

struct User: Codable {
    let id: String
    let type: String        //  тип пользователя s - спортсмен / t - тренер
    let name: String
    let email: String
    let iconUrl: String
    let trainerId: String
    let lastDate: String    // дата последней синхронизации измерений
    let json: String        // json с измерениями спортсмена
    let settings: String    //  на будущее
    let f1: String          //  резервное поле
    let f2: String          //  резервное поле
    let f3: String          //  резервное поле
    let f4: String          //  резервное поле
    let f5: String          //  резервное поле
}
