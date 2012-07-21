//
//  AGAccessoryManager.m
//  AirGuitarSDK
//
//  Created by Ronald Mannak on 7/21/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGAccessoryManager.h"
#import "AGAccessory.h"

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
        _connectedAGAccessories = [[NSMutableDictionary alloc] initWithCapacity:3];
        _compatibleProtocolStrings = [NSArray arrayWithObjects: AG_PROTOCOL_STRING, nil]; // Future addition
        
        // Check if an Air Guitar compatible device is already connected
        for (EAAccessory *connectedAccessory in [EAAccessoryManager sharedAccessoryManager].connectedAccessories) {
            if ([[connectedAccessory protocolStrings] containsObject:AG_PROTOCOL_STRING]) {
                                 
                AGAccessory *accessory = [[AGAccessory alloc] initWithAccessory:connectedAccessory protocol:AG_PROTOCOL_STRING];
                NSString *key = [NSString stringWithFormat:@"%d", connectedAccessory.connectionID];
                [_connectedAGAccessories setObject:accessory forKey:key];
                
                if (_shouldSendNotifications) {
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"AGAccessoryDidConnect"
                     object:accessory];
                }
                DLog(@"Connected at init: %@", _connectedAGAccessories);
            }
        }
             
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
        
        AGAccessory *accessory = [[AGAccessory alloc] initWithAccessory:connectedAccessory protocol:AG_PROTOCOL_STRING];
        NSString *key = [NSString stringWithFormat:@"%d", connectedAccessory.connectionID];
        [_connectedAGAccessories setObject:accessory forKey:key];

        if (_shouldSendNotifications) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AGAccessoryDidConnect"
             object:accessory];
        }
        DLog(@"Connected List: %@", _connectedAGAccessories);
    }
}

- (void)accessoryDidDisconnect: (NSNotification *)notification {
 
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    // Return if a non-Air Guitar accessory was disconnected
    if (![[disconnectedAccessory protocolStrings] containsObject:AG_PROTOCOL_STRING]) return;
    
    // Remove the disconnected accessory from the connectedAGAccessory dictionary
    NSString *key = [NSString stringWithFormat:@"%d", disconnectedAccessory.connectionID];    
    [_connectedAGAccessories removeObjectForKey:key];
    if (_shouldSendNotifications) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"AGAccessoryDidDisconnect"
         object:nil];
    }
    
    DLog(@"Disconnected device: %@", disconnectedAccessory);
    DLog(@"Connected List: %@", _connectedAGAccessories);
}

@synthesize shouldSendNotifications = _shouldSendNotifications,
            connectedAGAccessories = _connectedAGAccessories,
            compatibleProtocolStrings = _compatibleProtocolStrings;

@end
