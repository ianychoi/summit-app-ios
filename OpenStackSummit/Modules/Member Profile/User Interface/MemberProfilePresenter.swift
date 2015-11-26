//
//  MemberProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/2/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMemberProfilePresenter {
    var speakerId: Int { get set }
    var attendeeId: Int { get set }
    
    func viewLoad()
}

public class MemberProfilePresenter: NSObject, IMemberProfilePresenter {
    
    var memberProfileWireframe: IMemberProfileWireframe!
    var interactor: IMemberProfileInteractor!
    var viewController: IMemberProfileViewController!
    var isLoggedMemberProfile = false
    public var speakerId = 0
    public var attendeeId = 0
    
    public func viewLoad() {
        showPersonProfile(PersonDTO())
        
        isLoggedMemberProfile = false
        if (speakerId > 0) {
            showSpeakerProfile()
        }
            
        else if (attendeeId > 0){
            showAttendeeProfile()
        }
        else {
            if let currentMember = interactor.getCurrentMember() {
                isLoggedMemberProfile = true
                if currentMember.speakerRole != nil {
                    speakerId = currentMember.speakerRole!.id
                    showPersonProfile(currentMember.speakerRole!, error: nil)
                }
                else {
                    attendeeId = currentMember.attendeeRole!.id
                    showPersonProfile(currentMember.attendeeRole!, error: nil)
                }
            }
        }
    }
    
    func showSpeakerProfile() {
        self.viewController.showActivityIndicator()
        self.interactor.getSpeakerProfile(self.speakerId) { speaker, error in
            self.showPersonProfile(speaker, error: error)
        }
    }
    
    func showAttendeeProfile() {
        self.viewController.showActivityIndicator()
        self.interactor.getAttendeeProfile(self.attendeeId) { attendee, error in
            self.showPersonProfile(attendee, error: error)
        }
    }
    
    func showPersonProfile(person: PersonDTO?, error: NSError? = nil) {
        dispatch_async(dispatch_get_main_queue(),{
            if (error != nil) {
                self.viewController.handlerError(error!)
                return
            }
            
            self.viewController.name = person!.name
            self.viewController.personTitle = person!.title
            self.viewController.picUrl = person!.pictureUrl
            self.viewController.twitter = person!.twitter
            self.viewController.bio = person!.bio
            self.viewController.hideActivityIndicator()
        })
    }
    
    /*public func requestFriendship() {
        if (!interactor.isLoggedIn()) {
            memberProfileWireframe.showLoginView()
        }
        
        interactor.requestFriendship(memberId) { error in
            if (error != nil) {
                self.viewController.handlerError(error!)
                return
            }
            self.viewController.didFinishFriendshipRequest()
        }
    }*/
}