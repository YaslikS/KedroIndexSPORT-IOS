//
//  Measure+CoreDataProperties.swift
//  KerdoIndexSPORT
//
//  Created by Вячеслав Переяслов on 31.01.2023.
//
//

import Foundation
import CoreData


extension Measure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Measure> {
        return NSFetchRequest<Measure>(entityName: "Measure")
    }

    @NSManaged public var dad: Double
    @NSManaged public var date: String?
    @NSManaged public var id: Int32
    @NSManaged public var kerdoIndex: Double
    @NSManaged public var number: Int32
    @NSManaged public var pulse: Double

}

extension Measure : Identifiable {

}
