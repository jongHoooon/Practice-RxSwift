//
//  Memo.swift
//  RxMemo
//
//  Created by JongHoon on 2022/10/18.
//

import Foundation
import RxDataSources
import CoreData
import RxCoreData

struct Memo: Equatable, IdentifiableType {
    var content: String
    var insertDate: Date
    var identity: String
    
    init(content: String, insertData: Date = Date()) {
        self.content = content
        self.insertDate = insertData
        self.identity = "\(insertData.timeIntervalSinceReferenceDate)"
    }
    
    init(original: Memo, updatedContent: String) {
        self = original
        self.content = updatedContent
    }
}

extension Memo: Persistable {
    static var entityName: String {
        return "Memo"
    }
    
    static var primaryAttributeName: String {
        return "identity"
    }
    
    init(entity: NSManagedObject) {
        content = entity.value(forKey: "content") as! String
        insertDate = entity.value(forKey: "insertDate") as! Date
        identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    func update(_ entity: NSManagedObject) {
        entity.setValue(content, forKey: "content")
        entity.setValue(insertDate, forKey: "insertDate")
        entity.setValue("\(insertDate.timeIntervalSinceReferenceDate)", forKey: "identity")
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
}
