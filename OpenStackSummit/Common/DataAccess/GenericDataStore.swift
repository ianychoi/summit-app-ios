//
//  GenericDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class GenericDataStore: NSObject {
    var realm = try! Realm()
    var trigger: ITrigger!
    
    public override init() {
        super.init()
    }
    
    public func getByIdLocal<T: BaseEntity>(id: Int) -> T? {
        let entity = realm.objects(T.self).filter("id = \(id)").first
        return entity
    }

    public func getAllLocal<T: BaseEntity>() -> [T] {
        let entities = realm.objects(T.self)
        return entities.map { $0 }
    }
    
    public func saveOrUpdateLocal<T: BaseEntity>(entity: T, completionBlock: ((T?, NSError?) -> Void)?) {
        try! realm.write {
            self.realm.add(entity, update: true)
        }
        
        if (trigger != nil) {
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Save) {
                () in
                
                completionBlock?(entity, nil)
            }
        }
        else {
            completionBlock?(entity, nil)
        }
    }
    
    public func deleteLocal<T: BaseEntity>(entity: T, completionBlock : (NSError? -> Void)!) {
        try! realm.write {
            self.realm.delete(entity)
        }

        if (trigger != nil) {
            trigger.run(entity, type: TriggerTypes.Post, operation: TriggerOperations.Delete) {
                () in
                
                if (completionBlock != nil) {
                    completionBlock(nil)
                }
            }
        }
        else {
            if (completionBlock != nil) {
                completionBlock(nil)
            }
        }
    }
}