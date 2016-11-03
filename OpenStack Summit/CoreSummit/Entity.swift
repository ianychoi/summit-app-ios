//
//  Entity.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Base CoreData Entity `NSManagedObject` subclass for CoreSummit.
public class Entity: NSManagedObject {
    
    /// The unique identifier of this entity.
    @NSManaged final var id: Int64
    
    /// The date this object was stored in its entirety.
    @NSManaged final var cached: NSDate?
}

// MARK: - Extensions

public extension NSManagedObjectModel {
    
    /// CoreData Managed Object Model for CoreSummit framework (OpenStack Foundation Summit).
    static var summitModel: NSManagedObjectModel {
        
        guard let bundle = NSBundle(identifier: "org.openstack.CoreSummit"),
            let modelURL = bundle.URLForResource("Model", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
            else { fatalError("Could not load managed object model") }
        
        return managedObjectModel
    }
}

public extension Entity {
    
    static var identifierProperty: String { return "id" }
    
    var identifier: Int { return Int(self.id) }
    
    func didCache() {
        
        self.cached = NSDate()
    }
    
    static func entity(in context: NSManagedObjectContext) -> NSEntityDescription {
        
        let className = NSStringFromClass(self as AnyClass)
        
        struct Cache {
            static var entities = [String: NSEntityDescription]()
        }
        
        // try to get from cache
        if let entity = Cache.entities[className] {
            
            return entity
        }
        
        // search for entity with class name
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel.entities
            .firstMatching({ $0.managedObjectClassName == className })
            else { fatalError("Could not find entity for \(self) in managed object context") }
        
        Cache.entities[className] = entity
        
        return entity
    }
    
    static func find(identifier: Int,
                     context: NSManagedObjectContext,
                     returnsObjectsAsFaults: Bool = true,
                     includesSubentities: Bool = true) -> Self? {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(longLong: Int64(identifier))
        
        return try! context.find(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
    
    /// Find or create.
    static func cached(identifier: Identifier,
                       context: NSManagedObjectContext,
                       returnsObjectsAsFaults: Bool = true,
                       includesSubentities: Bool = true) throws -> Self {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(longLong: Int64(identifier))
        
        return try context.findOrCreate(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
}

public extension CollectionType where Generator.Element: Entity {
    
    var identifiers: [Identifier] { return self.map { Int($0.id) } }
}

public extension CoreDataEncodable where Self: Unique, ManagedObject: Entity {
    
    @inline(__always)
    func cached(context: NSManagedObjectContext) throws -> ManagedObject {
        
        return try ManagedObject.cached(self.identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: true)
    }
}

internal extension NSManagedObjectContext {
    
    /// Caches to-many relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(encodables: [T]) throws -> Set<T.ManagedObject> {
        
        return try encodables.save(self)
    }
    
    /// Caches to-one relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(encodable: T?) throws -> T.ManagedObject? {
        
        return try encodable?.save(self)
    }
    
    /// Caches to-one relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(encodable: T) throws -> T.ManagedObject {
        
        return try encodable.save(self)
    }
    
    /// Returns faults for to-many relationships.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(identifiers: [Identifier]) throws -> Set<ManagedObject> {
        
        let managedObjects = try identifiers.map { try ManagedObject.cached($0, context: self, returnsObjectsAsFaults: true, includesSubentities: true) }
        
        return Set(managedObjects)
    }
    
    /// Returns faults for to-one relationship.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(identifier: Identifier?) throws -> ManagedObject? {
        
        guard let identifier = identifier
            else { return nil }
        
        return try ManagedObject.cached(identifier, context: self, returnsObjectsAsFaults: true, includesSubentities: true)
    }
    
    /// Returns faults for to-one relationship.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(identifier: Identifier) throws -> ManagedObject {
        
        return try ManagedObject.cached(identifier, context: self, returnsObjectsAsFaults: true, includesSubentities: true)
    }
}
