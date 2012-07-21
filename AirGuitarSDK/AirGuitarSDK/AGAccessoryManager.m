//
//  AGAccessoryManager.m
//  AirGuitarSDK
//
//  Created by Ronald Mannak on 7/21/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGAccessoryManager.h"

#define AG_PROTOCOL_STRING @"com.yobble.airguitar"

@interface AGAccessoryManager ()

@end

@implementation AGAccessoryManager

+ (id)sharedAccessoryManager {

    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; 
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        _connectedAGAccessories = [[NSMutableArray alloc] initWithCapacity:3];
        
        [[EAAccessoryManager sharedAccessoryManager]   registerForLocalNotifications];  
        
        // Register for all connect and disconnect 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    }
    return self;
}

- (void)dealloc {
    [[EAAccessoryManager sharedAccessoryManager]  unregisterForLocalNotifications];
}


#pragma mark - EAAccessory Notifications

- (void)accessoryDidConnect: (NSNotification *)notification {

    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    // Check if an Air Guitar compatible accessory was connected
    if ([[connectedAccessory protocolStrings] containsObject:AG_PROTOCOL_STRING]) {
        
        [_connectedAGAccessories addObject:connectedAccessory];
        // TODO: establishconnection
        // Create new AGAccessory object
        if (_shouldSendNotifications) {
            // TODO: fire new notification
        }
        NSLog(@"Connected List: %@", _connectedAGAccessories);
    }
}

- (void)accessoryDidDisconnect: (NSNotification *)notification {
 
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    // Return if a non-Air Guitar accessory was disconnected
    if (![[disconnectedAccessory protocolStrings] containsObject:AG_PROTOCOL_STRING]) return;
    
    // Delete AGAAccessory object
    [_connectedAGAccessories removeObject:disconnectedAccessory];
    if (_shouldSendNotifications) {
            // TODO: fire new notification
    }
    
    // Remove the disconnected accessory from the connectedAGAccessory array
    int disconnectedAccessoryIndex = 0;
    for(EAAccessory *accessory in _connectedAGAccessories) {
        if ([disconnectedAccessory connectionID] == [accessory connectionID]) {
            break;
        }
        disconnectedAccessoryIndex++;
    }
    
    if (disconnectedAccessoryIndex < [_connectedAGAccessories count]) {
        [_connectedAGAccessories removeObjectAtIndex:disconnectedAccessoryIndex];
        NSLog(@"Connected List: %@", _connectedAGAccessories);
	} else {
        NSLog(@"could not find disconnected accessory in accessory list");
    }
}

@synthesize shouldSendNotifications = _shouldSendNotifications,
            connectedAGAccessories = _connectedAGAccessories;

@end
