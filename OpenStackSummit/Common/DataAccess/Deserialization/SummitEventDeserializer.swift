//
//  SummitEventDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitEventDeserializer: NSObject, DeserializerProtocol {
    var deserializerFactory = DeserializerFactory()
    
    public func deserialize(json: JSON) -> BaseEntity {
        let summitEvent = SummitEvent()
        
        summitEvent.id = json["id"].intValue
        summitEvent.start = NSDate(timeIntervalSince1970: NSTimeInterval(json["start"].intValue))
        summitEvent.end = NSDate(timeIntervalSince1970: NSTimeInterval(json["end"].intValue))
        summitEvent.title = json["title"].stringValue
        summitEvent.eventDescription = json["description"].stringValue
        
        var deserializer = deserializerFactory.create(DeserializerFactories.EventType)
        summitEvent.eventType = deserializer.deserialize(json["eventType"]) as! EventType

        deserializer = deserializerFactory.create(DeserializerFactories.SummitType)
        var summitType : SummitType
        for (_, summitTypeJSON) in json["summitTypes"] {
            summitType = deserializer.deserialize(summitTypeJSON) as! SummitType
            summitEvent.summitTypes.append(summitType)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactories.Venue)
        
        let jsonCategory = json["presentationCategory"]
        if (jsonCategory.int != nil) {
            deserializer = deserializerFactory.create(DeserializerFactories.Presentation)
            let presentation = deserializer.deserialize(json) as! Presentation
            
            summitEvent.presentation = presentation

            deserializer = deserializerFactory.create(DeserializerFactories.VenueRoom)
            summitEvent.venueRoom = deserializer.deserialize(json["location"]) as? VenueRoom
        }
        else {
            deserializer = deserializerFactory.create(DeserializerFactories.Venue)
            summitEvent.venue = deserializer.deserialize(json["location"]) as? Venue
        }
        
        return summitEvent
    }
}