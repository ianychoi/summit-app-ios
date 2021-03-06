//
//  EventDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

extension Event.DataUpdate: Updatable {
    
    @inline(__always)
    static func find(_ identifier: Identifier, context: NSManagedObjectContext) throws -> Entity? {
        
        return try EventManagedObject.find(identifier, context: context)
    }
    
    /// update current summit with Data Update
    func write(_ context: NSManagedObjectContext, summit: SummitManagedObject) throws -> Entity {
        
        let managedObject = try EventManagedObject.cached(self.identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        
        managedObject.summit = summit
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.socialDescription = socialDescription
        managedObject.start = start
        managedObject.end = end
        managedObject.allowFeedback = allowFeedback
        managedObject.averageFeedback = averageFeedback
        managedObject.rsvp = rsvp
        managedObject.attachment = attachment
        
        managedObject.track = try context.relationshipFault(track)
        managedObject.eventType = try context.relationshipFault(type)
        managedObject.sponsors = try context.relationshipFault(sponsors)
        managedObject.tags = try context.relationshipFault(tags)
        managedObject.location = try context.relationshipFault(location)
        managedObject.presentation = try context.relationshipFault(presentation)
        managedObject.videos = try context.relationshipFault(videos)
        
        managedObject.didCache()
        
        return managedObject
    }
}
