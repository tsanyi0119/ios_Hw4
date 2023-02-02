//
//  LocatDatabase.swift
//  MessageBoard
//
//  Created by imac-1681 on 2023/1/18.
//

import Foundation
import RealmSwift
class LocalDatabase: NSObject{
    
    static let DataDao = LocalDatabase()
    
    func fetchData(finish: @escaping (Results<MessageTable>) -> Void){
        DispatchQueue.global().async {
            let realm = try! Realm()
            let results = realm.objects(MessageTable.self)
            finish(results)
        }
    }
    
    func addData(message: Message){
        let realm = try! Realm()
        let table = MessageTable()
        table.name = message.name
        table.content = message.content
        table.createTimestamp = message.createTimestamp
        table.updateTimestamp = message.updateTimestamp
        
        do{
            try realm.write{
                realm.add(table)
            }
        }catch{
            print("Realm Add Failed:\(error.localizedDescription)")
        }
    }
    
    func deleteData(message:Message){
        let realm = try!Realm()
        let delteMessage = realm.objects(MessageTable.self).filter{
            $0.createTimestamp == message.createTimestamp
        }.first
        
        do{
            try realm.write{
                realm.delete(delteMessage!)
            }
        }catch{
            print("Realm Deleta Failed : \(error.localizedDescription)")
        }
    }
    
    func updateData(message:Message){
        let realm = try! Realm()
        let upDateMessage = realm.objects(MessageTable.self).where{
            $0.createTimestamp == message.createTimestamp
        }
        
        do{
            try realm.write{
                upDateMessage[0].name = message.name
                upDateMessage[0].content = message.content
                upDateMessage[0].updateTimestamp = message.updateTimestamp
            }
        }catch{
            print("Realm Update Failed:\(error.localizedDescription)")
        }
    }
    
    
}

class MessageTable: Object {
    
    @Persisted var name: String
    @Persisted var content: String
    @Persisted var createTimestamp: Int64
    @Persisted var updateTimestamp: Int64
}
